# frozen_string_literal: true

# Recurring task to send daily reminders to members
class DailyReminderTask < UnitTask
  def perform
    return unless unit.events.published.imminent.count.positive?

    Rails.logger.warn { "Sending Daily Reminders for #{unit.name}" }

    unit.members.find_each do |member|
      perform_for_member(member)
    end
  end

  def perform_for_member(member)
    Time.zone = member.unit.settings(:locale).time_zone
    return unless Flipper.enabled? :daily_reminder, member

    Rails.logger.warn { "Sending Daily Reminder to #{member.flipper_id}" }
    MemberNotifier.new(member).send_daily_reminder
  end
end
