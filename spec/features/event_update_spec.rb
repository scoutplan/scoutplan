# Test update of an Event

# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
describe "events", type: :feature do
  before do
    User.where(email: "test_admin@scoutplan.org").destroy_all
    User.where(email: "test_normal@scoutplan.org").destroy_all

    @admin_user  = FactoryBot.create(:user, email: "test_admin@scoutplan.org")
    @normal_user = FactoryBot.create(:user, email: "test_normal@scoutplan.org")

    @unit  = FactoryBot.create(:unit)
    @event = FactoryBot.create(:event, :draft, unit: @unit, title: "Draft Event")

    @admin_member = @unit.memberships.create(user: @admin_user, role: "admin", status: :active)
    @normal_member = @unit.memberships.create(user: @normal_user, role: "member", status: :active)

    login_as(@admin_user, scope: :user)
  end

  describe "update" do
    it "updates the event" do
      visit edit_unit_event_path(@unit, @event)
      fill_in "event_title", with: "Updated Event Title"
      click_button "Save"
      @event.reload
      expect(@event.title).to eq("Updated Event Title")
      expect(page).to have_current_path(unit_event_path(@unit, @event))
      expect(page).to have_content("Updated Event Title")
    end
  end

  describe "notifications" do
    it "notifies when switch is on" do
      visit edit_unit_event_path(@unit, @event)
      fill_in "event_title", with: "Updated Event Title"
      check "event_notify_members"
      expect { click_button "Save" }.to change(Message, :count).by(1)
    end

    it "doesn't notify when switch is off" do
      visit edit_unit_event_path(@unit, @event)
      fill_in "event_title", with: "Updated Event Title"
      expect { click_button "Save" }.to change(Message, :count).by(0)
    end
  end
end
# rubocop:enable Metrics/BlockLength
