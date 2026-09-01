# Runs on a recurring schedule (see config/recurring.yml). Finds work due in the next LOOKAHEAD
# and enqueues it with wait_until so each job still fires at exactly the right minute.
#
# The database is the source of truth; the queue is only a short-range timer. Event reminders used
# to be enqueued from an after_commit the moment an event was saved, which left a scheduled row per
# event sitting in the queue for up to a year -- jobs that outlived a queue backend migration,
# carried stale arguments, and needed an updated_at equality check to decide whether they were
# still valid. Scanning a short window instead means nothing queued is ever more than LOOKAHEAD old.
#
# LOOKAHEAD deliberately exceeds the run interval so consecutive runs overlap: a run missed during
# a deploy is covered by the next one instead of silently skipping a day of notifications. That is
# only safe because every job this enqueues is idempotent -- Event#remind! and RsvpLastCallJob check
# for an existing Noticed record, and the digest and nag check their *_last_ran_at setting.
class ScheduledJobDispatcherJob < ApplicationJob
  queue_as :default

  LOOKAHEAD = 30.hours
  # Also pick up run times that fell just behind us, so a late run still sends rather than skips.
  CATCHUP = 6.hours

  def perform
    Unit.find_each do |unit|
      schedule_digest(unit)
      schedule_rsvp_nag(unit)
    end

    schedule_event_reminders
    schedule_rsvp_last_calls
  end

  private

  def window
    @window ||= (CATCHUP.ago..LOOKAHEAD.from_now)
  end

  # Reminders fire REMINDER_LEAD_TIME before the start, shifted into the unit's business hours,
  # so the exact time can only be computed in Ruby. This SQL range is a generous prefilter --
  # business-hours shifting moves a time within its own day, never further.
  def candidate_events
    Event.published
         .where(starts_at: (window.first - 2.days)..(window.last + 3.days))
         .includes(:unit, :event_category)
  end

  def schedule_event_reminders
    candidate_events.find_each do |event|
      run_time = event.reminder_run_time
      next unless run_time && window.cover?(run_time)

      EventReminderJob.set(wait_until: run_time).perform_later(event.id)
      Rails.logger.info("ScheduledJobDispatcher: scheduled reminder for #{event.title} at #{run_time}")
    end
  end

  def schedule_rsvp_last_calls
    candidate_events.rsvp_required.find_each do |event|
      run_time = event.last_call_run_time
      next unless run_time && window.cover?(run_time)

      RsvpLastCallJob.set(wait_until: run_time).perform_later(event.id)
      Rails.logger.info("ScheduledJobDispatcher: scheduled last call for #{event.title} at #{run_time}")
    end
  end

  def schedule_digest(unit)
    return unless unit.settings(:communication).digest == "true"

    run_time = SendWeeklyDigestJob.next_run_time(unit)
    return unless window.cover?(run_time)

    SendWeeklyDigestJob.set(wait_until: run_time).perform_later(unit.id)
    Rails.logger.info("ScheduledJobDispatcher: scheduled digest for #{unit.name} at #{run_time}")
  end

  def schedule_rsvp_nag(unit)
    return unless RsvpNagJob.enabled?(unit)

    run_time = RsvpNagJob.next_run_time(unit)
    return unless run_time && window.cover?(run_time)

    RsvpNagJob.set(wait_until: run_time).perform_later(unit.id)
    Rails.logger.info("ScheduledJobDispatcher: scheduled RSVP nag for #{unit.name} at #{run_time}")
  end
end
