# frozen_string_literal: true

require "test_helper"

class SpreadsheetRowsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @unit     = create(:unit)
    @admin    = create(:unit_membership, :admin, unit: @unit)
    @member   = create(:unit_membership, unit: @unit, role: "member")
    @category = @unit.event_categories.find_by(name: "Troop Meeting")
    @event    = create(:event,
                       unit:           @unit,
                       event_category: @category,
                       status:         :published,
                       starts_at:      14.days.from_now,
                       ends_at:        14.days.from_now + 2.hours)
  end

  test "an admin inserts a draft row before the target event" do
    sign_in @admin.user
    existing_ids = @unit.events.pluck(:id)

    assert_difference -> { @unit.events.count }, 1 do
      insert_before(@event)
    end

    assert_response :success

    # Event's default_scope already orders by starts_at, so .order(:created_at) would only append
    # to it -- identify the new row by id instead.
    inserted = @unit.events.where.not(id: existing_ids).first
    assert inserted.draft?, "inserted events should start as drafts"
    assert inserted.starts_at < @event.starts_at, "inserted event should precede the target"
  end

  test "a plain member cannot insert a row" do
    sign_in @member.user

    assert_no_difference -> { @unit.events.count } do
      insert_before(@event)
    end

    assert_redirected_to root_path
  end

  test "a signed-out visitor cannot insert a row" do
    assert_no_difference -> { @unit.events.count } do
      insert_before(@event)
    end

    assert_redirected_to new_user_session_path
  end

  test "the target event must belong to the current unit" do
    other_event = create(:event, unit: create(:unit), status: :published)
    sign_in @admin.user

    assert_no_difference -> { Event.count } do
      insert_before(other_event)
    end
  end

  private

  def insert_before(event)
    post spreadsheet_rows_unit_events_path(@unit),
         params:  { before: event.id },
         headers: TURBO_STREAM_HEADERS
  end
end
