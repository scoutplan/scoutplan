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

    @unit = FactoryBot.create(:unit)
    @event = FactoryBot.create(:event, :draft, unit: @unit, title: "Draft Event")

    @admin_member = @unit.memberships.create(user: @admin_user, role: "admin", status: :active)
    @normal_member = @unit.memberships.create(user: @normal_user, role: "member", status: :active)

    login_as(@admin_user, scope: :user)

    Time.zone = @unit.settings(:locale).time_zone
  end

  describe "create", js: true do
    it "creates a single event" do
      skip "submit button is off page"
      starts_at = 13.days.from_now.in_time_zone
      ends_at   = 14.days.from_now.in_time_zone
      event_title = Faker::Music::Rush.album

      visit(new_unit_event_path(@unit))

      fill_in :event_title, with: event_title
      page.find("#event_starts_at_date").set(starts_at.to_date)
      page.find("#event_ends_at_date").set(ends_at.to_date)
      select "Camping Trip", from: "event_event_category_id"

      expect { click_link_or_button "Schedule This Event" }.to change { Event.count }.by(1)
    end

    it "creates a series" do
      skip "need to convert to JS test"
      visit(new_unit_event_path(@unit))

      fill_in :event_title, with: "Event Title"
      fill_in :event_starts_at_date, with: 13.days.from_now
      fill_in :event_ends_at_date, with: 14.days.from_now
      select "Camping Trip", from: "event_event_category_id"
      select @unit.locations.first.display_address, from: "event_event_locations_attributes_0_location_id"
      check :event_repeats, visible: false
      fill_in :event_repeats_until, with: 10.weeks.from_now

      expect { click_link_or_button "Add This Event" }.to change { Event.count }.by_at_least(4)
      expect(Event.last.event_locations.count).to be_positive
    end

    it "toggles rsvp fields", js: true do
      # visit new_unit_event_path(@unit)
      # expect(page.find("#event_rsvp_closes_at", visible: :all).visible?).to be_falsey
      # check :event_requires_rsvp
      # expect(page.find("#event_rsvp_closes_at", visible: :all).visible?).to be_truthy
    end

    it "tags events" do
      skip "validation disabled for now"
      visit(new_unit_event_path(@unit))

      fill_in :event_title, with: Faker::Music::Rush.album
      fill_in :event_tag_list, with: "tag1, tag2"
      select "Camping Trip", from: "event_event_category_id"

      expect { click_link_or_button "Add This Event" }.to change { Event.count }.by(1)

      event = Event.last
      expect(event.tag_list.count).to eq(2)
    end

    it "re-renders when RSVP closes after the start date" do
      skip "validation disabled for now"

      starts_at = 13.days.from_now.in_time_zone
      ends_at   = 14.days.from_now.in_time_zone
      event_title = Faker::Music::Rush.album

      visit(new_unit_event_path(@unit))

      fill_in :event_title, with: event_title
      fill_in :event_starts_at_date, with: starts_at
      fill_in :event_ends_at_date, with: ends_at
      fill_in :event_starts_at_time, with: starts_at
      fill_in :event_ends_at_time, with: ends_at
      find('label[for="event_requires_rsvp"]').click
      fill_in :event_rsvp_closes_at, with: 20.days.from_now
      select "Camping Trip", from: "event_event_category_id"

      expect { click_link_or_button "Add This Event" }.to raise_exception(ActiveRecord::RecordInvalid)
    end

    # it "re-renders when RSVP closes after the start date" do
    #   skip "validation disabled for now"

    #   starts_at = 13.days.from_now.in_time_zone
    #   ends_at   = 14.days.from_now.in_time_zone
    #   event_title = Faker::Music::Rush.album

    #   visit(new_unit_event_path(@unit))

    #   fill_in :event_title, with: event_title
    #   page.find("#event_starts_at_date").set(starts_at.to_date)
    #   page.find("#event_ends_at_date").set(ends_at.to_date)
    #   page.find("#event_rsvp_closes_at", visible: false).set(20.days.from_now.to_date)
    #   page.find("#event_requires_rsvp_label").click
    #   select "Camping Trip", from: "event_event_category_id"

    #   # debugger

    #   # expect { click_link_or_button "Add This Event" }.to change { Event.count }.by(1)
    #   expect { click_link_or_button "Add This Event" }.to raise_exception(ActiveRecord::RecordInvalid)
    # end
  end
end
# rubocop:enable Metrics/BlockLength
