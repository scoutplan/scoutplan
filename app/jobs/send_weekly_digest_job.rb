# frozen_string_literal: true

class SendWeeklyDigestJob < ApplicationJob
  queue_as :default

  def perform(unit_id)
    @unit = Unit.find(unit_id)
    WeeklyDigestNotification.with(unit: @unit).deliver_later(@unit.members)
    SendWeeklyDigestJob.schedule_next_job(@unit)
  end

  def self.schedule_next_job(unit)
    SendWeeklyDigestJob.set(wait_until: next_run_time(unit)).perform_later(unit.id)
  end

  def self.next_run_time(unit)
    now = Time.now.in_time_zone(unit.time_zone)
    result = now.next_occurring(unit.settings(:communication).digest_day_of_week.to_sym)
    result.change(hour: unit.settings(:communication).digest_hour_of_day.to_i,
                  min: 0,
                  sec: 0).utc
  end
end
