module Event::Remindable
  extend ActiveSupport::Concern

  REMINDER_LEAD_TIME = 12.hours
  LAST_CALL_LEAD_TIME = 36.hours
  PREP_LEAD_TIME = 36.hours

  # These used to be enqueued from after_commit the moment an event was saved, which meant the
  # queue held a scheduled row per event for up to a year -- an irreversible decision made from
  # data that had a year to change. ScheduledJobDispatcherJob now scans a short window instead,
  # so the database is the source of truth and the queue is only a short-range timer. These
  # methods answer "when should this fire, if at all" and return nil when it shouldn't.

  def reminder_run_time
    return nil unless published? && !started?

    unit.datetime_in_business_hours(starts_at - REMINDER_LEAD_TIME)
  end

  def last_call_run_time
    return nil unless published? && !ended? && requires_rsvp?

    unit.datetime_in_business_hours(rsvp_closes_at - LAST_CALL_LEAD_TIME)
  end

  def enqueue_organization_prep_job!
    return unless published? && !ended?

    run_time = unit.datetime_in_business_hours(starts_at - PREP_LEAD_TIME)
    OrganizationPrepJob.set(wait_until: run_time).perform_later(id, updated_at)
  end

  def remind!
    return unless published? && !ended?
    return if Noticed::Event.where(record: self, type: "EventReminderNotifier").exists?

    EventReminderNotifier.with(record: self, event: self).deliver(notification_recipients)
  end
end
