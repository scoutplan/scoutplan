class RsvpNagJob < ApplicationJob
  DEFAULT_DAY_OF_WEEK = "Tuesday".freeze
  DEFAULT_HOUR_OF_DAY = 10

  queue_as :default

  def perform(unit_id)
    @unit = Unit.find(unit_id)
    return unless RsvpNagJob.enabled?(@unit)

    @unit.unit_memberships.each { |member| perform_for_member(member) }
    @unit.settings(:communication).update!(rsvp_nag_last_ran_at: DateTime.current)
  end

  def perform_for_member(member)
    return unless member.contactable?

    event = next_needing_rsvp(member)
    return unless event.present?
    return unless EventPolicy.new(member, event).rsvp?

    RsvpNagNotifier.with(record: event).deliver_later(member)
  end

  def next_needing_rsvp(member)
    events = @unit.events.published.rsvp_required.future.order(:starts_at)
    events = events.select { |event| event.rsvp_open? && FamilyRsvp.new(member, event).incomplete? }
    events&.first
  end

  def self.enabled?(unit)
    unit.settings(:communication).rsvp_nag == "true"
  end

  def self.next_run_time(unit)
    return unless enabled?(unit)

    Time.zone = unit.time_zone
    day_of_week = unit.settings(:communication).rsvp_nag_day_of_week.downcase
    hour_of_day = unit.settings(:communication).rsvp_nag_hour_of_day.to_i
    next_occurring(DateTime.current, day_of_week, hour_of_day).utc
  end
end
