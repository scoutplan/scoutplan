# Test creation of an Event

# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
describe "event_deletion", type: :feature do
  before do
    User.where(email: "test_admin@scoutplan.org").destroy_all
    User.where(email: "test_normal@scoutplan.org").destroy_all

    @admin_user  = FactoryBot.create(:user, email: "test_admin@scoutplan.org")
    @normal_user = FactoryBot.create(:user, email: "test_normal@scoutplan.org")

    @unit  = FactoryBot.create(:unit)
    @event = FactoryBot.create(:event, :cancelled, unit: @unit, title: "Cancelled Event")

    @admin_member = @unit.memberships.create(user: @admin_user, role: "admin", status: :active)
    @normal_member = @unit.memberships.create(user: @normal_user, role: "member", status: :active)

    login_as(@admin_user, scope: :user)
  end

  describe "edit view" do
    it "has a Delete link if it's Cancelled" do
      visit edit_unit_event_path(@unit, @event)
      expect(page).to have_button(I18n.t("events.form.delete_caption"))
    end

    it "has a Delete link if it's Draft" do
      @event.update!(status: :draft)
      visit edit_unit_event_path(@unit, @event)
      expect(page).to have_button(I18n.t("events.form.delete_caption"))
    end

    it "doesn't have a Delete link if it's Published" do
      @event.update!(status: :published)
      visit edit_unit_event_path(@unit, @event)
      expect(page).not_to have_button(I18n.t("events.form.delete_caption"))
    end
  end

  describe "perform deletion" do
    it "deletes an event" do
      visit edit_unit_event_path(@unit, @event)
      expect { click_link_or_button(I18n.t("events.form.delete_caption")) }.to change { Event.count }.by(-1)
      expect(page).to have_current_path(list_unit_events_path(@unit))
    end
  end
end
# rubocop:enable Metrics/BlockLength
