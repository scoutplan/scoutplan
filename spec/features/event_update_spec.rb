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

  describe "edit page" do
    before { visit edit_unit_event_path(@unit, @event) }

    it "renders as a full page rather than a modal" do
      expect(page).to have_field("event_title")
      expect(page).not_to have_css("[role='dialog']", visible: :all)
    end

    it "offers a way back to the event without saving" do
      expect(page).to have_link(@event.title, href: unit_event_path(@unit, @event))
    end

    it "puts the save control in the top nav" do
      expect(page).to have_css("nav #accept")
    end

    it "keeps the overlay frame that the cancel-event flow targets" do
      expect(page).to have_css("turbo-frame#modal_overlay", visible: :all)
    end
  end
end
