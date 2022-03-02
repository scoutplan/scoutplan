# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
describe "news items", type: :feature do
  before do
    @admin_member = FactoryBot.create(:member, :admin)
    @unit = @admin_member.unit
    login_as @admin_member.user
  end

  describe "drafts page" do
    before do
      @news_item = FactoryBot.create(:news_item, unit: @unit)
    end

    it "creates a draft" do
    end

    it "deletes a draft" do
    end

    it "edits a draft" do
    end
  end

  # we may not need these specs anymore
  describe "digest settings" do
    it "navigates when legacy digest settings are in place" do
      @unit.settings(:communication).update! digest_schedule: "blah"
      path = unit_newsletter_drafts_path(@unit)
      visit path
      expect(page).to have_current_path(path)
    end

    it "navigates when digest task doesn't exist" do
      path = unit_newsletter_drafts_path(@unit)
      visit path
      expect(page).to have_current_path(path)
    end

    it "navigates when digest task exists" do
      task = @unit.tasks.find_or_create_by(key: "digest", type: "UnitDigestTask")
      task.schedule.add_recurrence_rule IceCube::Rule.weekly.day(1).hour_of_day(8)
      task.save_schedule
      path = unit_newsletter_drafts_path(@unit)
      visit path
      expect(page).to have_current_path(path)
    end
  end
end
# rubocop:enable Metrics/BlockLength
