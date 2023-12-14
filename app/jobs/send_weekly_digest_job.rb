class SendWeeklyDigestJob < ApplicationJob
  queue_as :default

  def perform(unit_id, timestamp)
    unit = Unit.find(unit_id)
    return unless timestamp ? timestamp == unit.settings(:communication).digest_config_timestamp : true && unit.settings(:communication).digest == "true"

    ap unit.members.count
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

  # An extension to DateTime.next_occuring that allows you to also specify the hour of day
  # SendWeeklyDigestJob.next_occurring(Time.current, :monday, 8)
  # SendWeeklyDigestJob.next_occurring(Time.current, "monday", 8)
  # SendWeeklyDigestJob.next_occurring(Time.current, 1, 8)
  def self.next_occurring(time, day_of_week, hour_of_day)
    day_of_week = DateAndTime::Calculations::DAYS_INTO_WEEK(day_of_week) if day_of_week.is_a?(Integer)
    day_of_week_number = DateAndTime::Calculations::DAYS_INTO_WEEK[day_of_week.to_sym]

    return time.change(hour: hour_of_day, min: 0, sec: 0) if day_of_week_number == time.wday && hour_of_day > time.hour

    time.next_occurring(day_of_week.to_sym).change(hour: hour_of_day, min: 0, sec: 0)
  end
end
