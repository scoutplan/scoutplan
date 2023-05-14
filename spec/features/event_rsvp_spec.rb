# frozen_string_literal: true

require "rails_helper"

describe "event_rsvp", type: :feature do
  before do
    @member = FactoryBot.create(:member, :adult)
    @unit = @member.unit

    @child = FactoryBot.create(:member, :youth, unit: @unit)
    @member.child_relationships.create(child_unit_membership: @child)

    @event = FactoryBot.create(:event, :requires_rsvp, unit: @unit)
    login_as(@member.user)
  end

  it "records a youth rsvp" do
    path = unit_event_edit_rsvps_path(@unit, @event)
    visit path
    expect(page).to have_current_path(path)
    radio = page.find("#event_members_#{@child.id}_event_rsvp_response_declined", visible: false)
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
end
