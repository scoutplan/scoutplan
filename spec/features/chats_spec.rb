# frozen_string_literal: true

require "rails_helper"

describe "chats", type: :feature do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @event = FactoryBot.create(:event, :requires_rsvp, :published, unit: @unit)
    login_as(@member.user)
  end

  it "visits the event page" do
    visit unit_event_path(@unit, @event)
    expect(page).to have_current_path(unit_event_path(@unit, @event))
  end
end
