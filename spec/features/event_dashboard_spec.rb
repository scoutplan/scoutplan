require "rails_helper"

describe "Event Dashboard", type: :feature do
  before do
    @member = FactoryBot.create(:unit_membership, :admin)
    @unit = @member.unit
    @unit.update(allow_youth_rsvps: true)
    @event = FactoryBot.create(:event, :requires_rsvp, :published, unit: @unit, allow_youth_rsvps: true)
    @child = FactoryBot.create(:unit_membership, unit: @unit, member_type: "youth", allow_youth_rsvps: true)
    @member.child_relationships.create(child_unit_membership: @child)
    @child_rsvp = @event.event_rsvps.create!(member: @child, response: "accepted_pending", respondent: @child)
    login_as(@member.user, scope: :user)
  end

  it "sets up correctly" do
    expect(@member.children.count).to eq(1)
    expect(@event.event_rsvps.count).to eq(1)
  end

  it "shows youth RSVP on dashboard" do
    puts @member.inspect
    path = dashboard_unit_event_path(@unit, @event)
    visit path
    expect(page).to have_content(@child.display_name)
  end
end