# frozen_string_literal: true

require 'sidekiq-scheduler'

# job called via sidekiq-scheduler
# to send daily reminders
class DailyReminderSender
  include Sidekiq::Worker
  attr_accessor :force_run

  def perform
    Rails.logger.warn 'Running Daily Reminder job'

    Unit.all.each do |unit|
      perform_for_unit(unit)
    end
  end

  # is it time for this unit to run its weekly digest?
  # hardwired for 7 AM daily
  def time_to_run?(member, current_time)
    return true if force_run
    return true if member.unit.settings(:utilities).fire_scheduled_tasks

    # current_time.hour == 7 && current_time.min.zero?
    current_time.hour == 7 && current_time.min.zero?
  end

  private

  def perform_for_unit(unit)
    return unless unit.settings(:communication).daily_reminder != 'none'
    return unless unit.events.published.imminent.count.positive?

    Rails.logger.warn "Sending Daily Reminders for #{unit.name}"

    unit.members.each do |member|
      perform_for_member(member)
    end

    unit.settings(:communication).update! last_daily_reminder_sent_at: DateTime.now
  end

  def perform_for_member(member)
    Time.zone = member.unit.settings(:locale).time_zone
    return unless Flipper.enabled? :daily_reminder, member
    return unless time_to_run?(member, Time.zone.now)

    Rails.logger.warn "Sending Daily Reminder to #{member.flipper_id}"
    MemberNotifier.send_daily_reminder(member)
  end
end
