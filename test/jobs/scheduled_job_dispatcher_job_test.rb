# frozen_string_literal: true

require "test_helper"

class ScheduledJobDispatcherJobTest < ActiveSupport::TestCase
  setup do
    @unit     = create(:unit)
    @category = @unit.event_categories.find_by(name: "Camping Trip")
    @unit.settings(:communication).update!(digest: "false", rsvp_nag: "false")
  end

  test "enqueues a reminder for an event whose reminder time falls in the window" do
    event = published_event(starts_at: 20.hours.from_now)
    assert event.reminder_run_time.present?

    assert_enqueued_with(job: EventReminderJob, args: [event.id]) do
      ScheduledJobDispatcherJob.perform_now
    end
  end

  test "ignores events whose reminder time is beyond the lookahead" do
    published_event(starts_at: 30.days.from_now)

    assert_no_enqueued_jobs only: EventReminderJob do
      ScheduledJobDispatcherJob.perform_now
    end
  end

  test "ignores drafts" do
    published_event(starts_at: 20.hours.from_now).update!(status: :draft)

    assert_no_enqueued_jobs only: EventReminderJob do
      ScheduledJobDispatcherJob.perform_now
    end
  end

  test "saving an event no longer enqueues anything by itself" do
    assert_no_enqueued_jobs only: [EventReminderJob, RsvpLastCallJob] do
      published_event(starts_at: 20.hours.from_now).update!(title: "Renamed")
    end
  end

  test "enqueues a last call only for events that require an RSVP" do
    with_rsvp = published_event(starts_at: 60.hours.from_now, requires_rsvp: true,
                                rsvp_closes_at: 50.hours.from_now)
    without   = published_event(starts_at: 60.hours.from_now)

    assert with_rsvp.last_call_run_time.present?
    assert_nil without.last_call_run_time

    assert_enqueued_with(job: RsvpLastCallJob, args: [with_rsvp.id]) do
      ScheduledJobDispatcherJob.perform_now
    end
  end

  test "overlapping runs re-enqueue, and the job itself is the idempotency boundary" do
    event = published_event(starts_at: 20.hours.from_now)

    ScheduledJobDispatcherJob.perform_now
    ScheduledJobDispatcherJob.perform_now
    assert_equal 2, enqueued_jobs.count { |j| j["job_class"] == "EventReminderJob" },
                 "the dispatcher does not dedupe; Event#remind! does"

    # First delivery creates the Noticed record; the second run must send nothing further.
    perform_enqueued_jobs(only: EventReminderJob)
    assert Noticed::Event.where(record: event, type: "EventReminderNotifier").exists?

    assert_no_difference -> { Noticed::Event.where(record: event).count } do
      event.remind!
    end
  end

  test "EventReminderJob still accepts the legacy trailing argument" do
    event = published_event(starts_at: 20.hours.from_now)

    assert_nothing_raised { EventReminderJob.perform_now(event.id, event.updated_at) }
  end

  private

  def published_event(starts_at:, **attrs)
    create(:event, { unit: @unit, event_category: @category, status: :published,
                     starts_at: starts_at, ends_at: starts_at + 2.hours }.merge(attrs))
  end
end
