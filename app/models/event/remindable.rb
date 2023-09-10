# frozen_string_literal: true

# adds remind capability to Events
module Event::Remindable
  extend ActiveSupport::Concern

  LEAD_TIME = 12.hours.freeze

  included do
    after_commit :create_reminder_job!
  end

  def create_reminder_job!
    return unless published? && !ended?

    run_time = starts_at - LEAD_TIME
    run_time = unit.in_business_hours(run_time) if ENV["RAILS_ENV"] == "production"
    EventReminderJob.set(wait_until: run_time).perform_later(id, updated_at)
  end

  def remind!
    return unless published?
    return if ended?

    EventReminderNotification.with(event: self).deliver_later(notification_recipients)
  end
end
