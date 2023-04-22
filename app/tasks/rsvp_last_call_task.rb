# frozen_string_literal: true

# a daily task to solicit responses before an event's RSVPs close
class RsvpLastCallTask < UnitTask
  TASK_KEY = "rsvp_last_call"
  DEFAULT_HOUR = 10 # 10:00 AM local time

  def description
    "RSVP last call"
  end

  def perform
    Rails.logger.info { "Performing RsvpLastCallTask for #{taskable}"}
    unit.members.each do |member|
      perform_for_member(member)
    rescue StandardError => e
      Rails.logger.error { e.message }
    end
    super
  end

  # set up default schedule daily at 10 AM
  def setup_schedule
    return if schedule_hash.present?

    rule = IceCube::Rule.daily.hour_of_day(DEFAULT_HOUR).minute_of_hour(0)
    schedule.start_time = DateTime.now.in_time_zone
    schedule.add_recurrence_rule rule
    save_schedule
  end

  private

  def perform_for_member(member)
    notifier = RsvpLastCallNotifier.new(member)
    notifier.perform
  end
end
