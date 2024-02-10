class SendWeeklyDigestJob < ApplicationJob
  DEFAULT_DAY_OF_WEEK = "Sunday".freeze
  DEFAULT_HOUR_OF_DAY = 9

  queue_as :default

  attr_reader :unit, :timestamp

  def perform(unit_id, timestamp = nil)
    @unit, @timestamp = Unit.find(unit_id), timestamp
    return unless should_run? && settings_are_current?

    WeeklyDigestNotifier.with(unit: unit).deliver_later(unit.members)
    schedule_next_job!
    unit.settings(:communication).update!(digest_last_ran_at: DateTime.current)
  end

  def schedule_next_job!
    self.class.schedule_next_job(unit)
  end

  ### Class methods
  def self.schedule_next_job(unit)
    return unless unit.settings(:communication).digest == "true"

    Time.zone = unit.time_zone
    timestamp = DateTime.current
    unit.settings(:communication).update!(digest_config_timestamp: timestamp)
    SendWeeklyDigestJob.set(wait_until: next_run_time(unit)).perform_later(unit.id, timestamp)
  end

  def self.next_run_time(unit)
    Time.zone = unit.time_zone
    day_of_week = unit.settings(:communication).digest_day_of_week.downcase
    hour_of_day = unit.settings(:communication).digest_hour_of_day.to_i
    next_occurring(DateTime.current, day_of_week, hour_of_day).utc
  end

  private

  def should_run?
    unit.settings(:communication).digest == "true"
  end

  def settings_are_current?
    return true unless timestamp.present?

    timestamp.present? && timestamp == unit.settings(:communication).config_timestamp
  end
end
