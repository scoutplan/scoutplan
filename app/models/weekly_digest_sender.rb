# frozen_string_literal: true

require 'sidekiq-scheduler'

# job called via cron-like mechanism to send weekly digests
# (in this case, sidekiq-scheduler)
class WeeklyDigestSender
  include Sidekiq::Worker
  attr_accessor :force_run

  def perform
    logger.info 'Sending digests...'

    Unit.all.each do |unit|
      perform_for_unit(unit)
    end
  end

  # is it time for this unit to run its weekly digest?
  # hardwired for 10 AM on Sunday
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

    return unless unit.settings(:communication).weekly_digest.present?
    return unless time_to_run?(unit, right_now)

    unit.members.each do |member|
      perform_for_member(member)
    end

    unit.settings(:communication).last_digest_sent_at = DateTime.now
  end

  def perform_for_member(member)
    return unless Flipper.enabled? :weekly_digest, member

    logger.info "Sending digest to #{member.flipper_id}"
    MemberNotifier.send_digest(member)
  end
end
