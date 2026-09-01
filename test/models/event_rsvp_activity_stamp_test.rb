# frozen_string_literal: true

require "test_helper"

# EventRsvp used to declare `belongs_to :event, touch: true`. events.updated_at doubles as the
# staleness guard for EventReminderJob / RsvpLastCallJob / OrganizerPrepJob, so every RSVP moved it
# and scheduled a duplicate reminder that later bailed. These lock in the split.
class EventRsvpActivityStampTest < ActiveSupport::TestCase
  setup do
    @unit   = create(:unit)
    @admin  = create(:unit_membership, :admin, unit: @unit)
    @member = create(:unit_membership, unit: @unit)
    @day    = 20.days.from_now
    @event  = create(:event, unit: @unit,
                             event_category: @unit.event_categories.find_by(name: "Camping Trip"),
                             status: :published, requires_rsvp: true, rsvp_closes_at: @day,
                             starts_at: @day, ends_at: @day + 2.hours).reload
  end

  test "an RSVP stamps rsvps_updated_at without moving updated_at" do
    before_updated = @event.updated_at
    assert_nil @event.rsvps_updated_at, "a fresh event has had no RSVP activity"

    rsvp!

    @event.reload
    assert_equal before_updated, @event.updated_at, "updated_at means 'an organizer edited this'"
    assert_not_nil @event.rsvps_updated_at, "rsvps_updated_at should be stamped"
  end

  test "an RSVP does not re-enqueue the reminder jobs" do
    reminders = -> { enqueued_jobs.count { |j| j["job_class"] == "EventReminderJob" } }
    last_call = -> { enqueued_jobs.count { |j| j["job_class"] == "RsvpLastCallJob" } }
    before = [reminders.call, last_call.call]

    rsvp!

    assert_equal before, [reminders.call, last_call.call],
                 "RSVPs must not schedule duplicate reminders"
  end

  test "editing the event still moves updated_at and re-enqueues" do
    before_updated = @event.updated_at
    before = enqueued_jobs.count { |j| j["job_class"] == "EventReminderJob" }

    @event.update!(title: "Renamed")

    assert @event.reload.updated_at > before_updated
    assert_operator enqueued_jobs.count { |j| j["job_class"] == "EventReminderJob" }, :>, before,
                    "a real edit should still supersede the scheduled reminder"
  end

  test "changing and withdrawing an RSVP both stamp the event" do
    rsvp = rsvp!
    after_create = @event.reload.rsvps_updated_at

    travel(1.second) { rsvp.update!(response: "declined", respondent: @admin) }
    after_update = @event.reload.rsvps_updated_at
    assert after_update > after_create, "an updated response should stamp"

    travel(2.seconds) { rsvp.destroy! }
    assert @event.reload.rsvps_updated_at > after_update, "a withdrawn RSVP should stamp"
  end

  test "destroying the event with RSVPs does not blow up on the stamp" do
    rsvp!
    assert_nothing_raised { @event.destroy! }
    assert_not Event.exists?(@event.id)
  end

  private

  def rsvp!
    create(:event_rsvp, event: @event, unit_membership: @member,
                        respondent: @admin, response: "accepted")
  end
end
