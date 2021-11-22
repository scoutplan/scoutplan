# frozen_string_literal: true

require 'sidekiq-scheduler'

# job called via cron-like mechanism to send weekly digests
# (in this case, sidekiq-scheduler)
class WeeklyDigestSender
  include Sidekiq::Worker
  attr_accessor :force_run

  def perform
    Rails.logger.warn { 'Weekly digest sender invoked' }

    Unit.all.each do |unit|
      perform_for_unit(unit)
    end
  end

  # is it time for this unit to run its weekly digest?
  # hardwired for 7 AM on Sunday
  def time_to_run?(unit, current_time)
    return true if force_run

    if unit.settings(:utilities).fire_scheduled_tasks
      unit.settings(:utilities).update!(fire_scheduled_tasks: false)
      return true
    end

    current_time.min.zero? && current_time.hour == 7 && current_time.sunday?
  end

  private

  def perform_for_unit(unit)
    Time.zone = unit.settings(:locale).time_zone
    right_now = Time.zone.now
    Rails.logger.warn { "Processing digest for unit #{unit.name}" }

    return unless unit.settings(:communication).weekly_digest.present?

    Rails.logger.warn { 'Weekly digest enabled for unit' }
    return unless time_to_run?(unit, right_now)

    Rails.logger.warn { 'Time to run' }

    unit.members.each do |member|
      perform_for_member(member)
    end

    unit.settings(:communication).last_digest_sent_at = DateTime.now
    Rails.logger.warn { "Weekly digest HWM set to #{unit.settings(:communication).last_digest_sent_at}" }
  end

  def perform_for_member(member)
    Rails.logger.warn "Processing digest for #{member.flipper_id}"
    return unless Flipper.enabled? :weekly_digest, member

    Rails.logger.warn "Sending digest to #{member.flipper_id}"
    MemberNotifier.send_digest(member)
  end
end
