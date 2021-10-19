# frozen_string_literal: true

require 'sidekiq-scheduler'

# job called via sidekiq-scheduler
# to send daily reminders
class DailyReminderSender
  include Sidekiq::Worker

  def perform
    logger.info 'Running Daily Reminder job'

    Unit.all.each do |unit|
      perform_for_unit(unit)
    end
  end

  # is it time for this unit to run its weekly digest?
  # hardwired for 8 AM daily
  def time_to_run?(unit, current_time)
    return true if unit.settings(:utilities).fire_scheduled_tasks

    current_time.hour == 7 && current_time.min.zero?
  end

  private

  def perform_for_unit(unit)
    Time.zone = unit.settings(:locale).time_zone
    right_now = Time.zone.now
    return unless unit.settings(:communication).daily_reminder != 'none'
    return unless time_to_run?(unit, right_now)
    return unless unit.events.published.imminent.count.positive?

    logger.info "Sending Daily Reminders for #{unit.name}"

    unit.members.each do |member|
      perform_for_member(member)
    end

    unit.settings(:communication).update! last_daily_reminder_sent_at: DateTime.now
  end

  def perform_for_member(member)
    return unless Flipper.enabled? :daily_reminder, member

    logger.info "Sending Daily Reminder to #{member.flipper_id}"
    MemberNotifier.send_daily_reminder(member)
  end
end
