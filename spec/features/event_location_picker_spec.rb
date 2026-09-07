# frozen_string_literal: true

require "rails_helper"

describe "the location rail", type: :feature do
  before do
    @member = FactoryBot.create(:member, :admin)
    @unit = @member.unit
    @event = FactoryBot.create(:event, :draft, unit: @unit)
    @event.event_locations.destroy_all
    login_as(@member.user, scope: :user)
  end

  def hall
    @hall ||= FactoryBot.create(:location, unit: @unit, name: "Parish Hall", address: "1 Main St")
  end

  describe "the chooser" do
    before { visit edit_unit_event_path(@unit, @event) }

    it "offers every location type" do
      EventLocation.location_types.keys.each do |type|
        expect(page).to have_css("[data-type-for='#{type}']", visible: :all)
      end
    end

    it "offers an online option alongside them" do
      expect(page).to have_content("Online meeting")
    end

    it "leaves every type enabled when nothing is assigned" do
      expect(page).to have_no_css("[data-type-for][disabled]", visible: :all)
    end
  end

  describe "when a place is already assigned" do
    before do
      FactoryBot.create(:event_location, event: @event, location: hall, location_type: "arrival")
      visit edit_unit_event_path(@unit, @event)
    end

    it "disables that type in the chooser" do
      expect(page).to have_css("[data-type-for='arrival'][disabled]", visible: :all)
    end

    it "leaves the other types available" do
      expect(page).to have_no_css("[data-type-for='departure'][disabled]", visible: :all)
    end

    it "hides the online option, since the states are exclusive" do
      expect(page).to have_css("[data-location-rail-target='onlineChoice'].hidden", visible: :all)
    end

    it "shows a chip naming the assigned place" do
      expect(page).to have_css("[data-location-type='arrival']", text: "Parish Hall", visible: :all)
    end
  end

  describe "when the event is online" do
    before do
      @event.update!(online: true, online_url: "https://zoom.us/j/123")
      visit edit_unit_event_path(@unit, @event)
    end

    it "withdraws the add control entirely" do
      expect(page).to have_css("[data-location-rail-target='adder'].hidden", visible: :all)
    end

    it "reveals the URL field" do
      expect(page).to have_css("input[name='event[online_url]']", visible: :all)
      expect(page).to have_no_css("[data-location-rail-target='onlineRow'].hidden", visible: :all)
    end

    it "carries the online flag in the form" do
      expect(page).to have_css("input[name='event[online]'][value='1']", visible: :all)
    end
  end

  describe "online without a URL yet" do
    it "is a valid state" do
      @event.update!(online: true, online_url: nil)

      expect(@event.reload).to be_online
      expect(@event.online_link?).to be(false)
    end
  end

  describe "saving" do
    it "ignores roles that were left empty" do
      @event.update!(event_locations_attributes: {
        "0" => {location_type: "departure", location_id: "", _destroy: "0"},
        "1" => {location_type: "arrival", location_id: hall.id, _destroy: "0"},
        "2" => {location_type: "activity", location_id: "", _destroy: "0"}
      })

      expect(@event.reload.event_locations.count).to eq(1)
      expect(@event.event_locations.first).to be_arrival
    end

    it "removes a role that was cleared" do
      existing = FactoryBot.create(:event_location, event: @event, location: hall,
        location_type: "arrival")

      @event.reload.update!(event_locations_attributes: {
        "1" => {id: existing.id, location_type: "arrival", location_id: "", _destroy: "1"}
      })

      expect(@event.reload.event_locations.count).to eq(0)
    end
  end

  describe "incomplete locations" do
    it "flags an address-less location in the browser" do
      FactoryBot.create(:location, unit: @unit, name: "Somewhere", address: nil)

      visit edit_unit_event_path(@unit, @event)

      expect(page).to have_css("[title='No address yet']", visible: :all)
    end
  end
end
