# frozen_string_literal: true

require 'sidekiq-scheduler'

# job called via cron-like mechanism to send weekly digests
# (in this case, sidekiq-scheduler)
class DailyReminderSender
  include Sidekiq::Worker

  def perform
    puts 'Sending daily reminder...'

    Unit.all.each do |unit|
      next unless unit.settings(:communication).daily_reminder.present?
      next unless time_to_run?(unit)
      next unless unit.events.published.imminent.count.positive?

      unit.members.each do |member|
        next unless Flipper.enabled? :daily_reminder, member

        MemberNotifier.send_daily_reminder(member)
      end

      unit.settings(:communication).last_daily_reminder_sent_at = DateTime.now
    end
  end

  # is it time for this unit to run its weekly digest?
  # hardwired for 8 AM daily
  def time_to_run?(unit)
    Time.zone = unit.settings(:locale).time_zone
    right_now = Time.zone.now
    right_now.hour == 8 && right_now.minute.zero?
  end
end
