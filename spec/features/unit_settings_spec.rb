# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
describe "unit settings", type: :feature do
  describe "as a non-admin" do
    before do
      @member = FactoryBot.create(:member, :non_admin)
      login_as @member.user
    end

    it "does not have a Unit Settings link" do
      visit unit_events_path(@member.unit)
      expect(page).not_to have_link("#{@member.unit.name} Settings", visible: false)
    end

    it "prevents Unit Settings page navigation" do
      expect { visit edit_unit_settings_path(@member.unit) }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "as an admin" do
    before do
      User.destroy_all
      @member = FactoryBot.create(:member, :admin)
      login_as @member.user
    end

    it "has a Unit Settings link" do
      visit unit_events_path(@member.unit)
      expect(page).to have_link("#{@member.unit.name} Settings", visible: false)
    end

    it "visits the unit settings page" do
      path = edit_unit_settings_path(@member.unit)
      visit path
      expect(page).to have_current_path(path)
    end
  end
end
# rubocop:enable Metrics/BlockLength
