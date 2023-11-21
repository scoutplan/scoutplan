# frozen_string_literal: true

require "rails_helper"

describe "event_rsvp", type: :feature do
  before do
    @member = FactoryBot.create(:member, :adult)
    @unit = @member.unit

    @child = FactoryBot.create(:member, :youth, unit: @unit)
    @member.child_relationships.create(child_unit_membership: @child)

    @event = FactoryBot.create(:event, :requires_rsvp, :published, unit: @unit)
    login_as(@member.user)
  end

  it "records a youth rsvp" do
    path = unit_event_edit_rsvps_path(@unit, @event)
    visit path
    expect(page).to have_current_path(path)
    radio = page.find("#unit_memberships_#{@child.id}_response_declined", visible: false)
    radio.click

    expect { page.find("#accept").click }.to change { EventRsvp.count }.by(1)
    expect(EventRsvp.last.response).to eq("declined")
  end

  it "works with incomplete RSVPs" do
    event = FactoryBot.create(:event, :requires_rsvp, unit: @unit, title: "RSVP Event")
    path = unit_event_edit_rsvps_path(@unit, event)
    visit path
    expect(page).to have_current_path(path)
  end

  it "allows authorized users to access the page" do
    event = FactoryBot.create(:event, :requires_rsvp, unit: @unit, title: "RSVP Event")
    path = unit_event_edit_rsvps_path(@unit, event)

    rsvp = EventRsvp.new(event: event, member: @child)
    policy = EventRsvpPolicy.new(@member, rsvp)
    expect(policy.create?).to be_truthy

    visit path
    expect(page).to have_current_path(path)
  end

  it "prevents unauthorized users from accessing the page" do
    logout(:user)
    login_as(@child.user)
    event = FactoryBot.create(:event, :requires_rsvp, unit: @unit, title: "RSVP Event")
    path = unit_event_edit_rsvps_path(@unit, event)

    rsvp = EventRsvp.new(event: event, member: @child)
    policy = EventRsvpPolicy.new(@child, rsvp)
    expect(policy.create?).to be_falsey

    visit path
    expect(page).to have_current_path(list_unit_events_path(@unit))
  end
end
