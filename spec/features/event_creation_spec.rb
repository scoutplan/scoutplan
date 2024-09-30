# Test creation of an Event

# frozen_string_literal: true

require "rails_helper"

describe "events", type: :feature do
  before do
    @member = FactoryBot.create(:member, :admin)
    @unit = @member.unit
    login_as(@member.user)
  end

  describe "new event" do
    it "creates a new event" do
      visit new_unit_event_path(@unit)
      fill_in "event_title", with: "New Event"
      expect { find("#accept").click }.to change { Event.count }.by(1)
    end
  end
end
