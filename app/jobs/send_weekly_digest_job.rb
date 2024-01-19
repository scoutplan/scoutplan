class SendWeeklyDigestJob < ApplicationJob
  queue_as :default

  def perform(unit_id, timestamp)
    unit = Unit.find(unit_id)
    return unless timestamp ? timestamp == unit.settings(:communication).digest_config_timestamp : true && unit.settings(:communication).digest == "true"

    WeeklyDigestNotification.with(unit: unit).deliver_later(unit.members)
    SendWeeklyDigestJob.schedule_next_job(unit)
    unit.settings(:communication).update!(digest_last_ran_at: DateTime.current)
  end

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
end
