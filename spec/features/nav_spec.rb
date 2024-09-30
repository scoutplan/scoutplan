# frozen_string_literal: true

# Test creation of an Event
require "rails_helper"

# rubocop:disable Metrics/BlockLength
describe "events", type: :feature do
  before do
    User.where(email: "test_admin@scoutplan.org").destroy_all
    User.where(email: "test_normal@scoutplan.org").destroy_all

    @admin_user  = FactoryBot.create(:user, email: "test_admin@scoutplan.org")
    @normal_user = FactoryBot.create(:user, email: "test_normal@scoutplan.org")

    @unit = FactoryBot.create(:unit)
    @event = FactoryBot.create(:event, :draft, unit: @unit, title: "Draft Event")

    @admin_member = @unit.memberships.create(user: @admin_user, role: "admin", status: :active)
    @normal_member = @unit.memberships.create(user: @normal_user, role: "member", status: :active)
  end

  describe "as an admin" do
    before do
      login_as(@admin_user, scope: :user)
      visit list_unit_events_path(@unit)
    end

    it "shows roster" do
      expect(page).to have_content(I18n.t("main_nav.members"))
    end
  end

  describe "as a non-admin" do
    before do
      login_as(@normal_user, scope: :user)
      visit list_unit_events_path(@unit)
    end

    it "doesn't show roster" do
      expect(page).not_to have_content("Member Roster")
    end

    it "doesn't show roster" do
      expect(page).not_to have_content("Newsletter")
    end

    it "doesn't show settings" do
      expect(page).not_to have_content("Unit Settings")
    end
  end
end
# rubocop:enable Metrics/BlockLength
