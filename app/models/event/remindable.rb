module Event::Remindable
  extend ActiveSupport::Concern

  REMINDER_LEAD_TIME = 12.hours
  LAST_CALL_LEAD_TIME = 36.hours
  PREP_LEAD_TIME = 36.hours

  included do
    after_commit :enqueue_reminder_job!
    after_commit :enqueue_last_call_job!
  end

  def enqueue_reminder_job!
    return unless published? && !started?

    run_time = unit.datetime_in_business_hours(starts_at - REMINDER_LEAD_TIME)
    EventReminderJob.set(wait_until: run_time).perform_later(id, updated_at)
  end

  def enqueue_last_call_job!
    return unless published? && !ended? && requires_rsvp?

    run_time = unit.datetime_in_business_hours(rsvp_closes_at - LAST_CALL_LEAD_TIME)
    RsvpLastCallJob.set(wait_until: run_time).perform_later(id, updated_at)
  end

  def enqueue_organization_prep_job!
    return unless published? && !ended?

    run_time = unit.datetime_in_business_hours(starts_at - PREP_LEAD_TIME)
    OrganizationPrepJob.set(wait_until: run_time).perform_later(id, updated_at)
  end

  def remind!
    return unless published? && !ended?

    EventReminderNotifier.with(event: self).deliver(notification_recipients)
  end
end
