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

    describe "edit affordance" do
      it "offers a member who can edit a way to reach the edit form" do
        admin = FactoryBot.create(:member, :admin, unit: @unit)
        login_as(admin.user, scope: :user)

        visit unit_event_path(@unit, @event)

        expect(page).to have_link("Edit", href: edit_unit_event_path(@unit, @event))
      end

      it "hides the edit affordance from a member who cannot edit" do
        visit unit_event_path(@unit, @event)

        expect(page).not_to have_link(href: edit_unit_event_path(@unit, @event))
      end
    end
  end
end
