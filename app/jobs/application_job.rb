# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  discard_on Noticed::ResponseUnsuccessful

  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

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
