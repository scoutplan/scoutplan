# frozen_string_literal: true

require "rails_helper"

describe "events", type: :feature do
  before do
    User.where(email: "test_admin@scoutplan.org").destroy_all
    User.where(email: "test_normal@scoutplan.org").destroy_all

    @member = FactoryBot.create(:member, :admin)
    @unit = @member.unit
    @event = FactoryBot.create(:event, :draft, unit: @unit, title: "Draft Event")

    login_as(@member.user, scope: :user)
  end

  describe "update" do
    it "updates the event" do
      new_title = "Updated Event Title"

      visit edit_unit_event_path(@unit, @event)
      fill_in "event_title", with: new_title
      click_button "Save"

      expect(page).to have_current_path(unit_event_path(@unit, @event))

      @event.reload
      expect(@event.title).to eq(new_title)
      expect(page).to have_content(@event.title)
    end
  end
end
