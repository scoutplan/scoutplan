# frozen_string_literal: true

require "rails_helper"

describe "event_rsvp", type: :feature do
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

  it "visits the event RSVP page" do
    path = unit_event_edit_rsvps_path(@unit, @event)
    visit path
    expect(page).to have_current_path(path)
  end

  it "works with incomplete RSVPs" do
    event = FactoryBot.create(:event, :requires_rsvp, unit: @unit, title: "RSVP Event")
    path = unit_event_edit_rsvps_path(@unit, event)
    visit path
    expect(page).to have_current_path(path)
  end
end
