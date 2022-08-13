# Test creation of an Event

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

  describe "create" do
    it "creates a single event" do
      visit(new_unit_event_path(@unit))
      fill_in :event_title, with: "Event Title"
      fill_in :event_location, with: "Anytown, USA"
      fill_in :event_starts_at_date, with: 13.days.from_now
      fill_in :event_ends_at_date, with: 14.days.from_now
      fill_in :event_venue_phone, with: "777-555-1212"
      select "Camping Trip", from: "event_event_category_id"
      expect { click_link_or_button "Add This Event" }.to change { Event.count }.by(1)
    end

    it "creates a series" do
      visit(new_unit_event_path(@unit))
      fill_in :event_title, with: "Event Title"
      fill_in :event_location, with: "Anytown, USA"
      fill_in :event_starts_at_date, with: 13.days.from_now
      fill_in :event_ends_at_date, with: 14.days.from_now
      select "Camping Trip", from: "event_event_category_id"
      check :event_repeats
      fill_in :event_repeats_until, with: 10.weeks.from_now
      expect { click_link_or_button "Add This Event" }.to change { Event.count }.by_at_least(4)
    end

    it "toggles rsvp fields", js: true do
      # visit new_unit_event_path(@unit)
      # expect(page.find("#event_rsvp_closes_at", visible: :all).visible?).to be_falsey
      # check :event_requires_rsvp
      # expect(page.find("#event_rsvp_closes_at", visible: :all).visible?).to be_truthy
    end
  end
end
# rubocop:enable Metrics/BlockLength
