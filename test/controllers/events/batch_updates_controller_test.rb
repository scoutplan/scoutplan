# frozen_string_literal: true

require "test_helper"

module Events
  class BatchUpdatesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @unit     = create(:unit)
      @admin    = create(:unit_membership, :admin, unit: @unit)
      @member   = create(:unit_membership, unit: @unit, role: "member")
      @category = @unit.event_categories.find_by(name: "Troop Meeting")
      @events   = Array.new(2) { |i| draft_event(10 + i) }
    end

    test "an admin publishes every selected event" do
      sign_in @admin.user
      batch_update(@events, status: "published")

      assert_response :success
      assert_equal %w[published published], @events.map { |e| e.reload.status }
    end

    test "publishing leaves a PaperTrail version" do
      sign_in @admin.user
      event = @events.first

      assert_difference -> { event.versions.count }, 1 do
        batch_update([event], status: "published")
      end

      version = event.reload.versions.reorder(:id).last
      assert_equal "update", version.event
      assert_includes version.object_changes.keys, "status"
    end

    test "publishing runs model callbacks and schedules the reminder" do
      sign_in @admin.user

      assert_enqueued_with(job: EventReminderJob) do
        batch_update([@events.first], status: "published")
      end
    end

    test "a plain member cannot publish" do
      sign_in @member.user
      batch_update(@events, status: "published")

      assert_redirected_to root_path
      assert_equal %w[draft draft], @events.map { |e| e.reload.status }
    end

    test "an unrecognized status is rejected" do
      sign_in @admin.user
      batch_update(@events, status: "bogus")

      assert_response :unprocessable_entity
      assert_equal %w[draft draft], @events.map { |e| e.reload.status }
    end

    test "events belonging to another unit are ignored" do
      other_event = create(:event, unit: create(:unit), status: :draft)

      sign_in @admin.user
      batch_update([other_event], status: "published")

      assert_response :unprocessable_entity
      assert_equal "draft", other_event.reload.status
    end

    test "nothing is published when one event in the batch is unauthorized" do
      sign_in @member.user
      batch_update(@events, status: "published")

      assert_equal %w[draft draft], @events.map { |e| e.reload.status }
    end

    private

    def draft_event(days_out)
      create(:event,
             unit:           @unit,
             event_category: @category,
             status:         :draft,
             starts_at:      days_out.days.from_now,
             ends_at:        days_out.days.from_now + 2.hours)
    end

    def batch_update(events, status:)
      post batch_updates_unit_events_path(@unit),
           params:  { event_ids: events.map(&:id).join(","), event: { status: status } },
           headers: TURBO_STREAM_HEADERS
    end
  end
end
