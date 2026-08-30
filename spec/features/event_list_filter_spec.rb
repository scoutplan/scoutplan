# frozen_string_literal: true

require "rails_helper"

# Exercises the client-side category radio filter on the agenda list
# (app/javascript/controllers/event_filter_controller.js). The pills behave like
# radio buttons: selecting one hides non-matching events; "All" restores everything.
describe "event list category filter", type: :feature, js: true do
  before do
    @unit  = FactoryBot.create(:unit)
    @admin = FactoryBot.create(:user)
    @unit.memberships.create(user: @admin, role: "admin", status: :active)

    @hiking  = FactoryBot.create(:event_category, unit: @unit, name: "Hiking")
    @meeting = FactoryBot.create(:event_category, unit: @unit, name: "Meeting")

    FactoryBot.create(:event, :published, unit: @unit, event_category: @hiking,
      title: "Mountain Hike", starts_at: 10.days.from_now, ends_at: 11.days.from_now)
    FactoryBot.create(:event, :published, unit: @unit, event_category: @meeting,
      title: "Troop Meeting", starts_at: 12.days.from_now, ends_at: 12.days.from_now)
    # a prior-month (past) event within the current season — hidden by default
    FactoryBot.create(:event, :published, unit: @unit, event_category: @hiking,
      title: "Old Campout", starts_at: 2.months.ago, ends_at: 2.months.ago + 1.day)

    # a category whose *only* event is in the past, so its pill has nothing to show by default
    @aquatics = FactoryBot.create(:event_category, unit: @unit, name: "Aquatics")
    FactoryBot.create(:event, :published, unit: @unit, event_category: @aquatics,
      title: "Old Swim Test", starts_at: 2.months.ago, ends_at: 2.months.ago + 1.day)

    login_as(@admin, scope: :user)
  end

  it "filters the list to a single category and back to all" do
    visit list_unit_events_path(@unit)

    expect(page).to have_content("Mountain Hike")
    expect(page).to have_content("Troop Meeting")

    click_on "Hiking"

    expect(page).to have_content("Mountain Hike")
    expect(page).not_to have_content("Troop Meeting")

    click_on "All"

    expect(page).to have_content("Mountain Hike")
    expect(page).to have_content("Troop Meeting")
  end

  it "hides past events by default and reveals them via the toggle" do
    visit list_unit_events_path(@unit)

    expect(page).to have_content("Mountain Hike")
    expect(page).not_to have_content("Old Campout")

    click_on "Show past events"
    expect(page).to have_content("Old Campout")

    click_on "Hide past events"
    expect(page).not_to have_content("Old Campout")
  end

  it "hides pills for categories with nothing in the visible range" do
    visit list_unit_events_path(@unit)

    expect(page).to have_css(".event-filter-pill", text: "Hiking")
    expect(page).not_to have_css(".event-filter-pill", text: "Aquatics")

    click_on "Show past events"
    expect(page).to have_css(".event-filter-pill", text: "Aquatics")

    click_on "Hide past events"
    expect(page).not_to have_css(".event-filter-pill", text: "Aquatics")
  end

  it "falls back to All when the selected category is hidden by the past toggle" do
    visit list_unit_events_path(@unit)
    click_on "Show past events"

    click_on "Aquatics"
    expect(page).to have_content("Old Swim Test")
    expect(page).not_to have_content("Mountain Hike")

    # Aquatics has nothing left to show, so the filter resets rather than stranding an empty list.
    click_on "Hide past events"
    expect(page).to have_content("Mountain Hike")
    expect(page).to have_content("Troop Meeting")
  end
end
