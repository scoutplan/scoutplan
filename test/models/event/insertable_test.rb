# frozen_string_literal: true

require "test_helper"

class Event::InsertableTest < ActiveSupport::TestCase
  setup do
    @unit = create(:unit)
  end

  test "the first event on the calendar predicts a generic title" do
    event = event_at("2026-09-30 10:00", category: "Troop Meeting")

    assert_equal Event::Insertable::INSERTED_EVENT_TITLE, event.new_event_before.title
  end

  # This is why the accidental inserts all came out as "Camping Trip": when the preceding event is
  # more than a week back, the prediction falls through to the unit's camping category.
  test "a gap of more than a week predicts the unit's camping category" do
    event_at("2026-09-20 10:00", category: "Troop Meeting", status: :published)
    event = event_at("2026-09-30 10:00", category: "Troop Meeting")

    assert_equal "Camping Trip", event.new_event_before.title
  end

  test "a preceding event in the same week hands down its own category" do
    event_at("2026-09-28 10:00", category: "Troop Meeting", status: :published)
    event = event_at("2026-09-30 10:00", category: "Hike")

    assert_equal "Troop Meeting", event.new_event_before.title
  end

  # `previous` resolves through series_scope, which only sees published events.
  test "a preceding draft is invisible to the prediction" do
    event_at("2026-09-28 10:00", category: "Troop Meeting", status: :draft)
    event = event_at("2026-09-30 10:00", category: "Hike")

    assert_equal Event::Insertable::INSERTED_EVENT_TITLE, event.new_event_before.title
  end

  test "the predicted event is a draft that starts before its anchor" do
    event = event_at("2026-09-30 10:00", category: "Troop Meeting")
    inserted = event.new_event_before

    assert inserted.draft?
    assert inserted.starts_at < event.starts_at
    assert_equal @unit, inserted.unit
  end

  private

  def event_at(timestamp, category:, status: :draft)
    starts_at = Time.zone.parse(timestamp)
    create(:event,
           unit:           @unit,
           event_category: @unit.event_categories.find_by(name: category),
           status:         status,
           starts_at:      starts_at,
           ends_at:        starts_at + 2.hours)
  end
end
