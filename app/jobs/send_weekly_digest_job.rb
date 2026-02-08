class SendWeeklyDigestJob < ApplicationJob
  DEFAULT_DAY_OF_WEEK = "Sunday".freeze
  DEFAULT_HOUR_OF_DAY = 9

  queue_as :default

  def perform(unit_id)
    unit = Unit.find(unit_id)
    return unless unit.settings(:communication).digest == "true"

    Rails.logger.info("SendWeeklyDigestJob: sending digest for #{unit.name}")
    WeeklyDigestNotifier.with(unit: unit).deliver(unit.members)
    unit.settings(:communication).update!(digest_last_ran_at: DateTime.current)
  end

  def self.next_run_time(unit)
    Time.zone = unit.time_zone
    day_of_week = unit.settings(:communication).digest_day_of_week.downcase
    hour_of_day = unit.settings(:communication).digest_hour_of_day.to_i
    next_occurring(DateTime.current, day_of_week, hour_of_day).utc
  end
end
