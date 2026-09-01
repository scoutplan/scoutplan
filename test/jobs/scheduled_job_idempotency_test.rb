# frozen_string_literal: true

require "test_helper"

# ScheduledJobDispatcherJob scans a window and enqueues; overlapping windows or a retry must not
# double-send. Neither job had any guard, so one duplicate enqueue meant every member of the unit
# received two digests.
class ScheduledJobIdempotencyTest < ActiveSupport::TestCase
  setup do
    @unit = create(:unit)
    create(:unit_membership, unit: @unit)
    @unit.settings(:communication).update!(digest: "true", rsvp_nag: "true")
  end

  test "the digest refuses to run twice inside the interval" do
    assert_not SendWeeklyDigestJob.ran_recently?(@unit), "a unit that has never run is eligible"

    SendWeeklyDigestJob.perform_now(@unit.id)
    @unit.reload
    assert SendWeeklyDigestJob.ran_recently?(@unit), "running should record the timestamp"

    assert_no_enqueued_jobs only: Noticed::EventJob do
      SendWeeklyDigestJob.perform_now(@unit.id)
    end
  end

  test "the digest runs again once the interval has passed" do
    SendWeeklyDigestJob.perform_now(@unit.id)
    @unit.reload

    travel(SendWeeklyDigestJob::MIN_RUN_INTERVAL + 1.hour) do
      assert_not SendWeeklyDigestJob.ran_recently?(@unit)
    end
  end

  test "the rsvp nag refuses to run twice inside the interval" do
    assert_not RsvpNagJob.ran_recently?(@unit)

    RsvpNagJob.perform_now(@unit.id)
    @unit.reload
    assert RsvpNagJob.ran_recently?(@unit)

    assert_no_enqueued_jobs only: Noticed::EventJob do
      RsvpNagJob.perform_now(@unit.id)
    end
  end

  test "a blank or unparseable timestamp is treated as never having run" do
    assert_nil SendWeeklyDigestJob.last_ran_at(@unit)

    @unit.settings(:communication).update!(digest_last_ran_at: "not a date")
    assert_nil SendWeeklyDigestJob.last_ran_at(@unit), "garbage must not raise or block the run"
    assert_not SendWeeklyDigestJob.ran_recently?(@unit)
  end

  test "a string timestamp is parsed, not compared as a string" do
    @unit.settings(:communication).update!(digest_last_ran_at: 1.hour.ago.iso8601)
    assert SendWeeklyDigestJob.ran_recently?(@unit)

    @unit.settings(:communication).update!(digest_last_ran_at: 3.days.ago.iso8601)
    assert_not SendWeeklyDigestJob.ran_recently?(@unit)
  end
end
