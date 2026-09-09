# frozen_string_literal: true

require "rails_helper"

describe "minimum headcount toggles", type: :feature do
  before do
    @member = FactoryBot.create(:member, :admin)
    @unit = @member.unit
    login_as(@member.user, scope: :user)
  end

  def visit_form(event)
    visit edit_unit_event_path(@unit, event)
  end

  describe "with no minimums set" do
    before do
      @event = FactoryBot.create(:event, :draft, unit: @unit,
        min_headcount_adult: nil, min_headcount_youth: nil)
      visit_form(@event)
    end

    it "offers a switch for each minimum" do
      expect(page).to have_content("Minimum adult headcount")
      expect(page).to have_content("Minimum youth headcount")
    end

    it "leaves both switches off" do
      expect(page).to have_unchecked_field("show_min_headcount_adult", visible: :all)
      expect(page).to have_unchecked_field("show_min_headcount_youth", visible: :all)
    end

    it "hides both fields" do
      expect(page).to have_css("[data-enable-target='field'].hidden", count: 2, visible: :all)
    end
  end

  describe "with an adult minimum set" do
    before do
      @event = FactoryBot.create(:event, :draft, unit: @unit,
        min_headcount_adult: 2, min_headcount_youth: nil)
      visit_form(@event)
    end

    it "switches that minimum on, and leaves the other off" do
      expect(page).to have_checked_field("show_min_headcount_adult", visible: :all)
      expect(page).to have_unchecked_field("show_min_headcount_youth", visible: :all)
    end

    it "reveals the adult field and keeps the youth field hidden" do
      expect(page).to have_css("[data-enable-target='field'].hidden", count: 1, visible: :all)
      expect(page).to have_field("event_min_headcount_adult", with: "2", visible: :all)
    end
  end

  describe "the model predicates behind the switches" do
    it "treats a positive value as on" do
      event = FactoryBot.build(:event, min_headcount_adult: 3, min_headcount_youth: 1)

      expect(event).to be_requires_adult_headcount
      expect(event).to be_requires_youth_headcount
    end

    it "treats nil and zero as off" do
      event = FactoryBot.build(:event, min_headcount_adult: nil, min_headcount_youth: 0)

      expect(event).not_to be_requires_adult_headcount
      expect(event).not_to be_requires_youth_headcount
    end
  end

  describe "clearing a minimum" do
    it "removes it, so nothing is enforced out of sight" do
      event = FactoryBot.create(:event, :draft, unit: @unit, min_headcount_adult: 4)

      event.update!(min_headcount_adult: "")

      expect(event.reload.min_headcount_adult).to be_nil
      expect(event).not_to be_requires_adult_headcount
    end
  end
end
