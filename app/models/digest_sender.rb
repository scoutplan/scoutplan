# frozen_string_literal: true

require 'sidekiq-scheduler'

# job called via cron-like mechanism to send weekly digests
# (in this case, sidekiq-scheduler). For test purposes it's
# possible to set the @unit and @current_datetime. Under normal
# production runtime, there's no need to set these
class DigestSender
  include Sidekiq::Worker

  attr_accessor :force_run, :unit

  def perform
    Rails.logger { "Digest sender invoked" }
    Unit.includes(:setting_objects).find_each do |unit|
      @unit = unit
      perform_for_unit
    end
  end

  # is it time for this unit to run its digest?
  # Current implementation is is probably naive. We may eventually need to track
  # sends on a per-member basis. For now, though, we set last-sent high watermarks
  # per unit. The IceCube gem performs scheduling logic. Thanks, IceCube gem.

  # rubocop:disable Metrics/AbcSize
  def time_to_run?
    return true if force_run
    return true if @unit.settings(:utilities).fire_scheduled_tasks
    return false unless @unit.settings(:communication).digest_schedule

    schedule = IceCube::Schedule.from_yaml(@unit.settings(:communication).digest_schedule)
    last_ran_at = @unit.settings(:communication).digest_last_sent_at&.localtime
    next_runs_at = schedule.next_occurrence(last_ran_at || 1.week.ago)

    Rails.logger.warn { "#{@unit.name} schedule is #{schedule}. Last run was at #{last_ran_at || 'never'}; next run is at #{next_runs_at}"}
    DateTime.now.after?(next_runs_at)
  end
  # rubocop:enable Metrics/AbcSize

  private

  # there's a potential race condition here that we're going to ignore for now:
  # if someone authored a NewsItem *while this task is running*, it could get
  # marked as sent. It's an edge case we'll come back to
  def perform_for_unit
    unit_setup
    return unless @unit.settings(:communication).digest_schedule.present?
    return unless time_to_run?

    Rails.logger.warn { "*** Time to run for #{@unit.name}" }

    @unit.members.find_each do |member|
      @member = member
      perform_for_member
    end

    unit_teardown
  end

  def perform_for_member
    Rails.logger.warn { "Processing digest for #{@member.short_display_name} (flipper ID #{@member.flipper_id})" }
    return unless Flipper.enabled? :digest, @member

    Rails.logger.warn { "Digest is enabled for #{@member.short_display_name} " }
    MemberNotifier.send_digest(@member)
  end

  def unit_setup
    Rails.logger { "Processing #{@unit.name}" }
    @unit.settings(:utilities).update!(fire_scheduled_tasks: false) # lower the force flag
    Time.zone = @unit.settings(:locale).time_zone
  end

  def unit_teardown
    # set the new highwatermark
    @unit.settings(:communication).update! digest_last_sent_at: DateTime.now
    Rails.logger.warn { "#{@unit.name} digest HWM set to #{@unit.settings(:communication).digest_last_sent_at}" }

    # dequeue news items
    NewsItem.mark_all_queued_as_sent_by(unit: @unit)
  end
end

# sample schedule YAML:
#
# ---\n:start_time: 2021-12-12 12:55:41.000000000 -05:00\n:rrules:\n- :validations:\n    :day:\n    - 1\n    :hour_of_day:\n    - 7\n    :minute_of_hour:\n    - 0\n    :second_of_minute:\n    - 0\n  :rule_type: IceCube::WeeklyRule\n  :interval: 1\n  :week_start: 0\n:rtimes: []\n:extimes: []\n

# every ten minutes:
# ---\n:start_time: 2021-12-23 09:50:17.000000000 -05:00\n:rrules:\n- :validations: {}\n  :rule_type: IceCube::MinutelyRule\n  :interval: 10\n:rtimes: []\n:extimes: []\n

# every one minute:
# ---\n:start_time: 2021-12-23 09:50:17.000000000 -05:00\n:rrules:\n- :validations: {}\n  :rule_type: IceCube::MinutelyRule\n  :interval: 1\n:rtimes: []\n:extimes: []\n