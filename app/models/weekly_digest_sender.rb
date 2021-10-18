# frozen_string_literal: true

require 'sidekiq-scheduler'

# job called via cron-like mechanism to send weekly digests
# (in this case, sidekiq-scheduler)
class WeeklyDigestSender
  include Sidekiq::Worker

  def perform
    logger.info 'Sending digests...'

    Unit.all.each do |unit|
      perform_for_unit(unit)
    end
  end

  # is it time for this unit to run its weekly digest?
  # hardwired for 10 AM on Sunday
  def time_to_run?(unit)
    return true if ENV['RAILS_ENV'] == 'test' # this feels funny1p

    if unit.settings(:utilities).fire_scheduled_tasks
      unit.settings(:utilities).update!(fire_scheduled_tasks: false)
      return true
    end

    Time.zone = unit.settings(:locale).time_zone
    right_now = Time.zone.now
    right_now.hour == 6 && right_now.minute.zero?
  end

  private

  def perform_for_unit(unit)
    next unless unit.settings(:communication).weekly_digest.present?
    next unless time_to_run?(unit)

    unit.members.each do |member|
      perform_for_member(member)
    end

    unit.settings(:communication).last_digest_sent_at = DateTime.now
  end

  def perform_for_member(member)
    next unless Flipper.enabled? :weekly_digest, member

    logger.info "Sending digest to #{member.flipper_id}"
    MemberNotifier.send_digest(member)
  end
end
