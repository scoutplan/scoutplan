# frozen_string_literal: true

require "test_helper"

class EventRsvpTallyTest < ActiveSupport::TestCase
  setup do
    @unit     = create(:unit)
    @category = @unit.event_categories.find_by(name: "Camping Trip")
    @adults   = create_list(:unit_membership, 3, unit: @unit)
    @youth    = create_list(:unit_membership, 3, :youth, unit: @unit)
    # Inactive members are outside the roster the tiles measure against.
    create(:unit_membership, :inactive, unit: @unit)
  end

  test "matches EventDashboard for a mix of responses" do
    event = event_with(accepted: 2, declined: 1)
    summary = EventRsvpTally.new(@unit, [event]).for(event)
    dashboard = EventDashboard.new(event)

    assert_equal dashboard.acceptance_count,     summary.acceptance_count
    assert_equal dashboard.declines_count,       summary.declines_count
    assert_equal dashboard.non_respondent_count, summary.non_respondent_count
    assert_in_delta dashboard.accept_rate,  summary.accept_rate,  0.0001
    assert_in_delta dashboard.decline_rate, summary.decline_rate, 0.0001
  end

  test "matches EventDashboard when nobody has responded" do
    event = event_with(accepted: 0, declined: 0)
    summary = EventRsvpTally.new(@unit, [event]).for(event)

    assert_equal 0, summary.acceptance_count
    assert_equal 0, summary.declines_count
    assert_equal EventDashboard.new(event).non_respondent_count, summary.non_respondent_count
    assert_equal 6, summary.non_respondent_count, "inactive members should not inflate the roster"
  end

  test "counts pending responses as intent, like the dashboard scopes do" do
    event = event_with(accepted: 0, declined: 0)
    # Both adults: UnitMembership validation rejects a youth acting as their own respondent.
    create(:event_rsvp, event: event, unit_membership: @adults.first,  response: "accepted_pending")
    create(:event_rsvp, event: event, unit_membership: @adults.second, response: "declined_pending")

    summary = EventRsvpTally.new(@unit, [event]).for(event)
    assert_equal 1, summary.acceptance_count
    assert_equal 1, summary.declines_count
    assert_equal 4, summary.non_respondent_count
  end

  test "resolves a whole collection without querying per event" do
    events = Array.new(3) { event_with(accepted: 1, declined: 0) }
    tally  = EventRsvpTally.new(@unit, events)

    after = count_queries { events.each { |e| tally.for(e) } }
    assert_equal 0, after, "for() should be pure arithmetic once loaded"
    assert_equal [1, 1, 1], events.map { |e| tally.for(e).acceptance_count }
  end

  test "returns zeroes for an empty collection without querying" do
    summary = EventRsvpTally.new(@unit, []).for(Event.new(id: 1))
    assert_equal 0, summary.acceptance_count
    assert_equal 0, summary.non_respondent_count
    assert_equal 0.0, summary.accept_rate, "an empty roster must not divide by zero"
  end

  private

  def event_with(accepted:, declined:)
    day = 10.days.from_now
    event = create(:event, unit: @unit, event_category: @category, status: :published,
                           requires_rsvp: true, rsvp_closes_at: day,
                           starts_at: day, ends_at: day + 2.hours)
    members = @adults + @youth
    accepted.times { |i| create(:event_rsvp, event: event, unit_membership: members[i], response: "accepted") }
    declined.times { |i| create(:event_rsvp, event: event, unit_membership: members[accepted + i], response: "declined") }
    event.reload
  end

  def count_queries
    n = 0
    sub = ActiveSupport::Notifications.subscribe("sql.active_record") do |*, payload|
      n += 1 unless payload[:name].to_s.match?(/SCHEMA|TRANSACTION/)
    end
    yield
    ActiveSupport::Notifications.unsubscribe(sub)
    n
  end
end
