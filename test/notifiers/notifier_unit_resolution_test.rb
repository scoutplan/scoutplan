# frozen_string_literal: true

require "test_helper"

# ScoutplanNotifier#unit was a bare stub returning nil. RsvpNagNotifier#feature_enabled? called
# unit.settings(...) on it, so every RSVP nag delivery raised NoMethodError inside the Noticed
# delivery job -- invisible until someone read solid_queue_failed_executions. 139 in three hours.
class NotifierUnitResolutionTest < ActiveSupport::TestCase
  setup do
    @unit  = create(:unit)
    @event = create(:event, unit: @unit,
                            event_category: @unit.event_categories.find_by(name: "Camping Trip"),
                            status: :published, requires_rsvp: true,
                            rsvp_closes_at: 10.days.from_now,
                            starts_at: 10.days.from_now, ends_at: 10.days.from_now + 2.hours)
  end

  test "the nag notifier resolves its unit from the record" do
    assert_equal @unit, RsvpNagNotifier.with(record: @event).unit
  end

  test "the nag notifier honours the unit setting instead of raising" do
    @unit.settings(:communication).update!(rsvp_nag: "true")
    assert RsvpNagNotifier.with(record: @event.reload).feature_enabled?

    @unit.settings(:communication).update!(rsvp_nag: "false")
    assert_not RsvpNagNotifier.with(record: @event.reload).feature_enabled?
  end

  test "the reminder notifier resolves its unit and honours its setting" do
    @unit.settings(:communication).update!(event_reminders: "true")
    notifier = EventReminderNotifier.with(record: @event.reload, event: @event.reload)

    assert_equal @unit, notifier.unit
    assert notifier.feature_enabled?
  end

  # An event whose unit has been deleted -- the same orphan case that produced RecordNotFound in
  # the worker logs. update_column bypasses the belongs_to validation to reproduce it.
  test "a missing unit skips quietly rather than raising" do
    @event.update_column(:unit_id, nil)
    orphan = @event.reload
    assert_nil orphan.unit

    assert_nothing_raised do
      assert_not RsvpNagNotifier.with(record: orphan).feature_enabled?
      assert_not EventReminderNotifier.with(record: orphan, event: orphan).feature_enabled?
    end
  end

  test "time_zone comes from the unit, not the application default" do
    @unit.settings(:locale).update!(time_zone: "Pacific Time (US & Canada)")

    assert_equal "Pacific Time (US & Canada)", RsvpNagNotifier.with(record: @event.reload).time_zone
  end
end
