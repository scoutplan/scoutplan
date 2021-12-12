# frozen_string_literal: true

require 'sidekiq-scheduler'

# job called via cron-like mechanism to send weekly digests
# (in this case, sidekiq-scheduler)
class WeeklyDigestSender
  include Sidekiq::Worker
  attr_accessor :force_run

  def perform
    Rails.logger.warn { '----------------------------' }
    Rails.logger.warn { 'Weekly digest sender invoked' }

    Unit.all.each_with_index do |unit|
      Rails.logger.warn { "Processing digest for unit #{unit.name}" }
      perform_for_unit(unit)
    end
  end

  # is it time for this unit to run its weekly digest?
  # hardwired for 7 AM on Sunday
  def time_to_run?(unit, current_time)
    return true if force_run
    return true if unit.settings(:utilities).fire_scheduled_tasks
    return false unless unit.settings(:communication).weekly_digest

    schedule = IceCube::Schedule.from_yaml(unit.settings(:communication).weekly_digest)
    Rails.logger.warn { "Schedule is #{schedule.to_s}" }
    Rails.logger.warn { "Next run is #{schedule.next_occurrence}" }
    DateTime.now.after?(schedule.next_occurrence(unit.settings(:communication).weekly_digest_last_sent_at || 1.week.ago))
  end

  private

  def perform_for_unit(unit)
    Rails.logger.warn { "Performing digest for unit #{unit.name}" }
    unit.settings(:utilities).update!(fire_scheduled_tasks: false)
    Rails.logger.warn { "Lowered fire flag "}
    Time.zone = unit.settings(:locale).time_zone
    right_now = Time.zone.now

    # Rails.logger.warn unit.settings(:communication).weekly_digest

    return unless unit.settings(:communication).weekly_digest.present?

    Rails.logger.warn { "Weekly digest enabled for #{unit.name}" }
    return unless time_to_run?(unit, right_now)

    Rails.logger.warn { "****" }
    Rails.logger.warn { "Time to run for #{unit.name}" }

    unit.members.each do |member|
      perform_for_member(member)
    end

    unit.settings(:communication).last_digest_sent_at = DateTime.now
    unit.save!
    Rails.logger.warn { "Weekly digest HWM set to #{unit.settings(:communication).last_digest_sent_at}" }

    # there's a potential race condition here that we're going to ignore for now:
    # if someone authored a NewsItem *while this task is running*, it could get
    # marked as sent. It's an edge case we'll come back to
    NewsItem.mark_all_queued_as_sent_by(unit: unit)
  end

  def perform_for_member(member)
    Rails.logger.warn { "Processing digest for #{member.flipper_id}" }
    return unless Flipper.enabled? :weekly_digest, member

    Rails.logger.warn { "Sending digest to #{member.flipper_id}" }
    MemberNotifier.send_digest(member)
  end
end

# sample schedule YAML:
#
# "---\n:start_time: 2021-12-12 12:55:41.000000000 -05:00\n:rrules:\n- :validations:\n    :day:\n    - 1\n    :hour_of_day:\n    - 7\n    :minute_of_hour:\n    - 0\n    :second_of_minute:\n    - 0\n  :rule_type: IceCube::WeeklyRule\n  :interval: 1\n  :week_start: 0\n:rtimes: []\n:extimes: []\n"