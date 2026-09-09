# frozen_string_literal: true

require "rails_helper"

describe "event cost", type: :feature do
  before do
    @member = FactoryBot.create(:member, :admin)
    @unit = @member.unit
    login_as(@member.user, scope: :user)
  end

  def event_with(adult:, youth:)
    FactoryBot.create(:event, :draft, unit: @unit, cost_adult: adult, cost_youth: youth)
  end

  describe "predicates" do
    it "reports no payment when both are zero" do
      event = FactoryBot.build(:event, cost_adult: 0, cost_youth: 0)

      expect(event).not_to be_requires_payment
      expect(event).not_to be_costs_differ
    end

    it "reports a single price when the two match" do
      event = FactoryBot.build(:event, cost_adult: 25, cost_youth: 25)

      expect(event).to be_requires_payment
      expect(event).not_to be_costs_differ
    end

    it "reports differing prices when they do not match" do
      event = FactoryBot.build(:event, cost_adult: 25, cost_youth: 10)

      expect(event).to be_costs_differ
    end

    # cost_adult is nullable, and this used to raise on nil
    it "tolerates a nil adult cost" do
      event = FactoryBot.build(:event, cost_adult: nil, cost_youth: 0)

      expect { event.requires_payment? }.not_to raise_error
      expect(event).not_to be_requires_payment
    end
  end

  describe "a free event" do
    before { visit edit_unit_event_path(@unit, event_with(adult: 0, youth: 0)) }

    it "leaves the cost switch off and the fields hidden" do
      expect(page).to have_unchecked_field("event_has_cost", visible: :all)
      expect(page).to have_css("[data-event-cost-target='costs'].hidden", visible: :all)
    end
  end

  describe "an event with one price" do
    before { visit edit_unit_event_path(@unit, event_with(adult: 25, youth: 25)) }

    it "switches cost on and reveals the fields" do
      expect(page).to have_checked_field("event_has_cost", visible: :all)
      expect(page).to have_no_css("[data-event-cost-target='costs'].hidden", visible: :all)
    end

    it "labels the single field per person and hides the youth field" do
      expect(page).to have_content("Cost per person")
      expect(page).to have_unchecked_field("costs_differ", visible: :all)
      expect(page).to have_css("[data-event-cost-target='youthRow'].hidden", visible: :all)
    end
  end

  describe "an event with differing prices" do
    before { visit edit_unit_event_path(@unit, event_with(adult: 25, youth: 10)) }

    it "switches the differs toggle on and reveals the youth field" do
      expect(page).to have_checked_field("costs_differ", visible: :all)
      expect(page).to have_no_css("[data-event-cost-target='youthRow'].hidden", visible: :all)
    end

    it "relabels the primary field for adults" do
      expect(page).to have_content("Adult cost")
      expect(page).to have_no_content("Cost per person")
    end
  end

  describe "section order" do
    it "places the headcount minimums after the RSVP dates and before cost" do
      visit edit_unit_event_path(@unit, event_with(adult: 0, youth: 0))
      text = page.text

      expect(text.index("Open RSVP from")).to be < text.index("Minimum adult headcount")
      expect(text.index("Minimum youth headcount")).to be < text.index("There is a cost to attend")
    end
  end
end
