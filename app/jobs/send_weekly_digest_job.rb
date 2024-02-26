class SendWeeklyDigestJob < ApplicationJob
  DEFAULT_DAY_OF_WEEK = "Sunday".freeze
  DEFAULT_HOUR_OF_DAY = 9

  queue_as :default

  attr_reader :unit, :timestamp

  # rubocop:disable Metrics/AbcSize
  def perform(unit_id, timestamp = nil)
    @unit, @timestamp = Unit.find(unit_id), timestamp
    Rails.logger.warn("Performing SendWeeklyDigestJob for {@unit.name}")
    return unless enabled_by_unit? && settings_are_current?

    Rails.logger.warn("Invoking WeeklyDigestNotifier")
    WeeklyDigestNotifier.with(unit: unit).deliver(unit.members)
    schedule_next_job!
    unit.settings(:communication).update!(digest_last_ran_at: DateTime.current)
  end
  # rubocop:enable Metrics/AbcSize

  def schedule_next_job!
    self.class.schedule_next_job(unit)
  end

  ### Class methods
  def self.schedule_next_job(unit)
    return unless unit.settings(:communication).digest == "true"

    Time.zone = unit.time_zone
    timestamp = DateTime.current
    unit.settings(:communication).update!(config_timestamp: timestamp)
    SendWeeklyDigestJob.set(wait_until: next_run_time(unit)).perform_later(unit.id, timestamp)
  end

  def self.next_run_time(unit)
    Time.zone = unit.time_zone
    day_of_week = unit.settings(:communication).digest_day_of_week.downcase
    hour_of_day = unit.settings(:communication).digest_hour_of_day.to_i
    next_occurring(DateTime.current, day_of_week, hour_of_day).utc
  end

  private

  def enabled_by_unit?
    result = unit.settings(:communication).digest
    Rails.logger.warn("Unit digest setting is #{result}")
    result == "true"
  end

  def settings_are_current?
    return true unless timestamp.present?

    config_timestamp = unit.settings(:communication).config_timestamp
    Rails.logger.warn("Timestamp argument is #{timestamp}. Config timestamp is #{config_timestamp}")
    timestamp.present? && timestamp == config_timestamp
  end
end
