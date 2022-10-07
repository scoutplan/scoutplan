# frozen_string_literal: true

# sends a message to a unit's members asking them to RSVP to the
# next event on the calendar where (a) RSVPs are still open,
# (b) event is less than 30 days away, and
# and (c) the member's family RSVP is incomplete
class RsvpNagTask < UnitTask
  TASK_KEY = "rsvp_nag"
  DEFAULT_DAY = :tuesday
  DEFAULT_HOUR = 10

  def description
    "RSVP nag"
  end

  def perform
    Rails.logger.info { "Performing RsvpNagTask for #{taskable}"}
    unit.members.each do |member|
      perform_for_member(member)
    rescue StandardError => e
      Rails.logger.error { e.message }
    end
    super
  end

  # set up default schedule for Tuesday mornings at 10 AM
  def setup_schedule
    return if schedule_hash.present?

    rule = IceCube::Rule.weekly.day(DEFAULT_DAY).hour_of_day(DEFAULT_HOUR).minute_of_hour(0)
    schedule.start_time = DateTime.now.in_time_zone
    schedule.add_recurrence_rule rule
    save_schedule
  end

  private

  def perform_for_member(member)
    return unless Flipper.enabled? :rsvp_nag, member

    notifier = RsvpNagNotifier.new(member)
    notifier.perform
  end
end
