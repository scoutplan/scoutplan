# frozen_string_literal: true

require "rails_helper"

describe "events", type: :feature do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @event = FactoryBot.create(:event, :published, unit: @unit)
    login_as(@member.user, scope: :user)
  end

  describe "show" do
    it "should display the event" do
      visit unit_event_path(@unit, @event)
      expect(page).to have_content(@event.title)
    end

    it "should display the event with a cost" do
      @new_event = FactoryBot.create(:event, :published, :with_cost, :requires_rsvp, unit: @unit)
      expect { visit unit_event_path(@unit, @new_event) }.not_to raise_error
    end
  end
end
