# frozen_string_literal: true

# Recurring task to send daily reminders to members
class DailyReminderTask < UnitTask
  def description
    I18n.t("tasks.daily_reminder_description")
  end

  def perform
    return if Flipper.enabled?(:event_reminder_jobs, unit)

    Time.zone = unit.settings(:locale).time_zone
    find_events
    send_reminders if @events.count.positive?
    super
  end

  # set up default schedule every day at 7 AM and 7 PM
  def setup_schedule
    return if schedule_hash.present?

    morning_rule = IceCube::Rule.daily.hour_of_day(7).minute_of_hour(0)
    evening_rule = IceCube::Rule.daily.hour_of_day(19).minute_of_hour(0)
    schedule.start_time = DateTime.now.in_time_zone
    schedule.add_recurrence_rule morning_rule
    schedule.add_recurrence_rule evening_rule

    save_schedule
  end

  private

  def find_events
    @events = unit.events.published.imminent
  end

  def send_reminders
    Rails.logger.warn { "Sending Daily Reminders for #{unit.name}" }

    unit.members.find_each do |member|
      perform_for_member(member)
    end
  end

  def perform_for_member(member)
    Rails.logger.warn { "Sending Daily Reminder to #{member.flipper_id}" }
    MemberNotifier.new(member).send_daily_reminder
  end
end
