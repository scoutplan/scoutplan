# Test creation of an Event

# frozen_string_literal: true

require "rails_helper"

describe "events", type: :feature do
  before do
    @member = FactoryBot.create(:member, :admin)
    @unit = @member.unit
    login_as(@member.user)
  end

  # describe "new event" do
  # it "creates a new event" do
  #   visit new_unit_event_path(@unit)
  #   fill_in "event_title", with: "New Event"
  #   expect { find("#accept", visible: false).click }.to change { Event.count }.by(1)
  # end

  # it "sets a location" do
  #   location = FactoryBot.create(:location, unit: @unit)
  #   visit new_unit_event_path(@unit)
  #   fill_in "event_title", with: "New Event"

  #   find("#add_event_location").click
  #   expect(page).to have_content(location.name)
  #   find("label", text: location.name, exact_text: true, visible: false).click
  #   find("button", text: "Set Event Location", exact_text: true, visible: false, wait: 5).click

  #   expect(page).to have_content(location.name)
  #   expect { find("#accept", visible: false).click }.to change { Event.count }.by(1)

  #   expect(Event.last.event_locations.count).to eq(1)
  # end
  # end

  describe "new event" do
    # it "creates a new event" do
    #   visit new_unit_event_path(@unit)
    #   fill_in "event_title", with: "New Event"
    #   expect { find("#accept", visible: false).click }.to change { Event.count }.by(1)
    # end

    it "sets a location", js: true do
      location = FactoryBot.create(:location, unit: @unit)
      visit new_unit_event_path(@unit)
      fill_in "event_title", with: "New Event"

      find("#add_event_location").click
      expect(page).to have_content(location.name)
      find("label", text: location.name, exact_text: true, visible: false).click
      find("button", text: "Set Event Location", exact_text: true, visible: false, wait: 5).click

      expect(page).to have_content(location.name)
      expect { find("#accept", visible: false).click }.to change { Event.count }.by(1)

      expect(Event.last.event_locations.count).to eq(1)
    end
  end
end
