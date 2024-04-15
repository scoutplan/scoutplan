# frozen_string_literal: true

require "rails_helper"

describe "planner", type: :feature do
  before :each do
    @admin_user  = FactoryBot.create(:user, email: "test_admin@scoutplan.org")
    @normal_user = FactoryBot.create(:user, email: "test_normal@scoutplan.org")

    @unit = FactoryBot.create(:unit)
    @meeting_category = @unit.event_categories.find_by(name: "Troop Meeting")
    4.times do |i|
      @event = FactoryBot.create(
        :event,
        :published,
        starts_at:      ((i * 7) + 0).days.from_now,
        ends_at:        ((i * 7) + 1).days.from_now,
        event_category: @meeting_category,
        unit:           @unit,
        title:          "Event #{i}"
      )
    end

    @admin_member = @unit.memberships.create(user: @admin_user, role: "admin", status: :active)
    @normal_member = @unit.memberships.create(user: @normal_user, role: "member", status: :active)

    login_as(@admin_user, scope: :user)
  end

  it "navigates to the planner page" do
    path = unit_plans_path(@unit)
    visit(path)
    expect(page).to have_current_path(path)
  end

  it "has the right number of event cards" do
    path = unit_plans_path(@unit)
    visit(path)
    event_cards = page.all(:css, ".event-card")
    expect(event_cards.count).to eq(@unit.events.count)
  end

  it "adds an activity" do
    path = unit_plans_path(@unit)
    visit(path)

    add_links = page.all(:css, ".event-activity-add-link")
    add_link = add_links.first
    add_link.click

    fill_in :event_activity_title, with: "Fun Activity!"
    expect { click_link_or_button("Add") }.to change { EventActivity.count }.by(1)
    expect(EventActivity.last.title).to eq("Fun Activity!")
  end
end
