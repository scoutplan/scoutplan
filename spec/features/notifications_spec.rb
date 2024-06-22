# frozen_string_literal: true

require "rails_helper"

describe "notifications", type: :feature do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @event = FactoryBot.create(:event, unit: @unit, title: Faker::Music::Rush.album)
    @event.rsvps.create(unit_membership: @member, response: :accepted, respondent: @member)
    EventRsvpOrganizerNotifier.with(event: @event, record: @event).deliver(@member)

    login_as(@member.user, scope: :user)
  end

  describe "index" do
    it "shows notifications" do
      path = unit_notifications_path(@unit)
      visit path
      expect(page).to have_content("Notifications")
      expect(page).to have_content("You have new RSVPs for #{@event.title}")
    end
  end
end
