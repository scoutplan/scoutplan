# frozen_string_literal: true

require "rails_helper"

describe "event_rsvp", type: :feature do
  before do
    @member = FactoryBot.create(:member, :adult)
    @unit = @member.unit

    @child = FactoryBot.create(:member, :youth, unit: @unit)
    @member.child_relationships.create(child_unit_membership: @child)

    @event = FactoryBot.create(:event, :requires_rsvp, :published, unit: @unit, rsvp_closes_at: 1.day.from_now)
    login_as(@member.user)
  end

  it "displays the event rsvp popup" do
    path = popup_unit_event_rsvps_path(@unit, @event)
    visit path
    expect(page).to have_current_path(path)
  end

  it "records a youth rsvp" do
    skip "need to JS this"
    path = new_unit_event_family_rsvp_path(@unit, @event)
    visit path
    expect(page).to have_current_path(path)
    radio = page.find("#unit_memberships_#{@child.id}_response_declined", visible: false)
    radio.click

    expect { page.find("#accept").click }.to change { EventRsvp.count }.by(1)
    expect(EventRsvp.last.response).to eq("declined")
  end

  it "works with incomplete RSVPs" do
    event = FactoryBot.create(:event, :requires_rsvp, unit: @unit, title: "RSVP Event")
    path = new_unit_event_family_rsvp_path(@unit, event)
    visit path
    expect(page).to have_current_path(path)
  end

  it "allows authorized users to access the page" do
    event = FactoryBot.create(:event, :requires_rsvp, unit: @unit, title: "RSVP Event")
    path = new_unit_event_family_rsvp_path(@unit, event)

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
    path = new_unit_event_family_rsvp_path(@unit, event)

    rsvp = EventRsvp.new(event: event, member: @child)
    policy = EventRsvpPolicy.new(@child, rsvp)
    expect(policy.create?).to be_falsey

    visit path
    expect(page).to have_current_path(list_unit_events_path(@unit))
  end

  it "works with time shifts", js: true do
    skip "works standalone but not in suite, need to debug"
    @event.event_shifts.create(name: "10-12")
    @event.event_shifts.create(name: "12-2")
    @event.event_shifts.create(name: "2-4")
    visit(unit_event_path(@unit, @event))
    page.find(".response-needed").click
    expect(page).to have_content("10-12")
    toggle_id = "#event_members_#{@member.id}_shifts_#{@event.event_shifts.first.id}_response_label"
    page.find(toggle_id).click
    expect { page.find("#rsvp_submit").click }.to change { EventRsvp.count }.by(2)
  end
end
