class RsvpNagJob < ApplicationJob
  DEFAULT_DAY_OF_WEEK = "Tuesday".freeze
  DEFAULT_HOUR_OF_DAY = 10

  queue_as :default

  attr_reader :unit

  def perform(unit_id, timestamp)
    @unit = Unit.find(unit_id)

    return unless RsvpNagJob.should_run?(unit) && RsvpNagJob.settings_are_current?(unit, timestamp)

    unit.unit_memberships.each { |member| perform_for_member(member) }
    RsvpNagJob.schedule_next_job(unit)
    unit.settings(:communication).update!(rsvp_nag_last_ran_at: DateTime.current)
  end

  def perform_for_member(member)
    return unless member.contactable?

    event = next_needing_rsvp(member)
    return unless event.present?
    return unless EventPolicy.new(member, event).rsvp?

    RsvpNagNotification.with(event: event).deliver_later(member)
  end

  def next_needing_rsvp(member)
    events = @unit.events.published.rsvp_required.future.order(:starts_at)
    events = events.select { |event| event.rsvp_open? && FamilyRsvp.new(member, event).incomplete? }
    events&.first
  end

  def self.schedule_next_job(unit)
    Time.zone = unit.time_zone
    timestamp = DateTime.current
    unit.settings(:communication).update!(rsvp_nag_config_timestamp: timestamp)
    RsvpNagJob.set(wait_until: next_run_time(unit)).perform_later(unit.id, timestamp)
  end

  def self.next_run_time(unit)
    return unless should_run?(unit)

    Time.zone = unit.time_zone
    day_of_week = unit.settings(:communication).rsvp_nag_day_of_week.downcase
    hour_of_day = unit.settings(:communication).rsvp_nag_hour_of_day.to_i
    next_occurring(DateTime.current, day_of_week, hour_of_day).utc
  end

  def self.should_run?(unit)
    unit.settings(:communication).rsvp_nag == "true"
  end

  def self.settings_are_current?(unit, timestamp)
    timestamp.present? && timestamp == unit.settings(:communication).config_timestamp
  end
end
