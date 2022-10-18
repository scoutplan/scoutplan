# frozen_string_literal: true

require "rails_helper"

# exercise the Locations facility
describe "locations", type: :feature do
  before do
    @admin = FactoryBot.create(:member, :admin)
    @unit = @admin.unit
    @event = FactoryBot.create(:event, unit: @unit)
    @location = FactoryBot.create(:location, unit: @unit)
    login_as(@admin.user, scope: :user)
  end

  it "visits the edit page" do
    path = edit_unit_location_path(@unit, @location)
    visit(path)
    expect(page).to have_current_path(path)

    fill_in :location_name,        with: "Paul's Boutique"
    fill_in :location_address,     with: "99 Rivington Street, New York, NY  10002"
    fill_in :location_phone,       with: "212-555-1212"
    fill_in :location_website,     with: "https://paulsboutique.mil"
    click_link_or_button "Save"

    # expect(page).to have_current_path edit_unit_event_path(@unit, @event)

    @location.reload

    expect(@location.name).to        eq("Paul's Boutique")
    expect(@location.address).to     eq("99 Rivington Street, New York, NY  10002")
    expect(@location.phone).to       eq("212-555-1212")
    expect(@location.website).to     eq("https://paulsboutique.mil")
  end

  it "visits the edit page when address is missing" do
    @location.update(address: nil, map_name: nil)
    path = edit_unit_location_path(@unit, @location)
    visit(path)
    expect(page).to have_current_path(path)
  end
end
