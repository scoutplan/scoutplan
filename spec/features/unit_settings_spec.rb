# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
describe "unit settings", type: :feature do
  describe "as a non-admin" do
    before do
      User.destroy_all
      @member = FactoryBot.create(:member, :non_admin)
      @unit = @member.unit
      login_as @member.user
    end

    it "does not have a Unit Settings link" do
      visit unit_events_path(@member.unit)
      expect(page).not_to have_link("Unit Settings", visible: false)
    end

    it "prevents Unit Settings page navigation" do
      expect { visit unit_settings_path(@unit) }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "as an admin" do
    before do
      User.destroy_all
      @member = FactoryBot.create(:member, :admin)
      @unit = @member.unit
      login_as @member.user
    end

    it "has a Unit Settings link" do
      visit unit_events_path(@member.unit)
      expect(page).to have_link("Unit Settings", visible: false)
    end

    it "visits the unit settings page" do
      path = unit_settings_path(@member.unit)
      visit path
      expect(page).to have_current_path(path)
    end

    it "visits the communication settings page" do
      path = unit_setting_path(@member.unit, category: "communications")
      visit path
      expect(page).to have_current_path(path)
    end

    describe "communication settings" do
      before do
        @unit.settings(:communication).daily_reminder = false
        @unit.settings(:communication).rsvp_nag = false
        @unit.settings(:communication).digest = false
        @unit.save
        @unit.reload
      end

      it "saves daily reminder settings" do
        expect(@unit.settings(:communication).daily_reminder).to be_falsey
        expect(@unit.tasks.count).to eq(0)

        visit unit_setting_path(@member.unit, category: "communications")
        page.find("#settings_communication_daily_reminder", visible: false).click
        click_button I18n.t("settings.buttons.save")

        @unit.reload
        expect(@unit.settings(:communication).daily_reminder).to be_truthy
        expect(@unit.tasks.count).to eq(1)
      end

      it "saves rsvp nag settings" do
        expect(@unit.settings(:communication).rsvp_nag).to be_falsey
        expect(@unit.tasks.count).to eq(0)

        visit unit_setting_path(@member.unit, category: "communications")
        page.find("#settings_communication_rsvp_nag", visible: false).click
        click_button I18n.t("settings.buttons.save")

        @unit.reload
        expect(@unit.settings(:communication).rsvp_nag).to be_truthy
        expect(@unit.tasks.count).to eq(1)
      end

      it "saves digest settings" do
        expect(@unit.settings(:communication).digest).to be_falsey
        expect(@unit.tasks.count).to eq(0)

        visit unit_setting_path(@member.unit, category: "communications")
        page.find("#settings_communication_digest", visible: false).click
        click_button I18n.t("settings.buttons.save")

        @unit.reload
        expect(@unit.settings(:communication).digest).to be_truthy
        expect(@unit.tasks.count).to eq(1)
      end

      it "saves all the settings" do
        expect(@unit.settings(:communication).digest).to be_falsey
        expect(@unit.tasks.count).to eq(0)

        visit unit_setting_path(@member.unit, category: "communications")
        page.find("#settings_communication_daily_reminder", visible: false).click
        page.find("#settings_communication_rsvp_nag", visible: false).click
        page.find("#settings_communication_digest", visible: false).click
        click_button I18n.t("settings.buttons.save")

        @unit.reload
        expect(@unit.settings(:communication).digest).to be_truthy
        expect(@unit.tasks.count).to eq(3)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
