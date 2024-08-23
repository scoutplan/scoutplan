# frozen_string_literal: true

# Test duplication of an Event

require "rails_helper"

describe "event_deletion", type: :feature do
  before do
    @admin = FactoryBot.create(:member, :admin)
    @unit = @admin.unit
    @event = FactoryBot.create(:event, :published, unit: @unit, title: "Source Event")
    login_as(@admin.user, scope: :user)
  end

  describe "new event page" do
    it "visits" do
      path = new_unit_event_path(@unit, source_event_id: @event.id)
      visit path
      expect(page).to have_current_path(path)
      # expect(page).to have_field("Title", with: @event.title)
    end
  end
end
