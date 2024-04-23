require "rails_helper"

describe "Event Dashboard", type: :feature do
  before do
    @member = FactoryBot.create(:unit_membership, :admin)
    @unit = @member.unit
    @admin = FactoryBot.create(:unit_membership, :admin, unit: @unit)
    @unit.update(allow_youth_rsvps: true)
    @event = FactoryBot.create(:event, :requires_rsvp, :published, unit: @unit, allow_youth_rsvps: true)
    @child = FactoryBot.create(:unit_membership, unit: @unit, member_type: "youth", allow_youth_rsvps: true)
    @member.child_relationships.create(child_unit_membership: @child)
    @child_rsvp = @event.event_rsvps.create!(member: @child, response: "accepted_pending", respondent: @child)
    login_as(@admin.user, scope: :user)
  end

  it "sets up correctly" do
    expect(@member.children.count).to eq(1)
    expect(@event.event_rsvps.count).to eq(1)
  end

  it "shows youth RSVP on dashboard" do
    path = dashboard_unit_event_path(@unit, @event)
    visit path
    expect(page).to have_content(@child.display_name)
  end

  describe "RSVPs" do
    it "allows admin to change RSVP", js: true do
      path = dashboard_unit_event_path(@unit, @event)
      visit path
      click_on @member.display_name
      modal = find(".modal-dialog")
      expect(modal).to have_content(@member.first_name)
      expect(modal).to have_content(@child.first_name)
      expect(modal).not_to have_content(@admin.first_name)
    end
  end

  describe "non-admin" do
    before do
      @member.update(role: :member)
      login_as(@member.user, scope: :user)
    end

    it "prevents dashboard access" do
      visit dashboard_unit_event_path(@unit, @event)
      expect(page).to have_current_path(list_unit_events_path(@unit))
    end
  end
end
