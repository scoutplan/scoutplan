# frozen_string_literal: true

# Test creation of an Event
require "rails_helper"

# rubocop:disable Metrics/BlockLength
describe "new unit", type: :feature do
  describe "unit creation" do
    before do
      user = FactoryBot.create(:user)
      login_as(user, scope: :user)
    end

    describe "positive cases" do
      it "creates a new unit" do
        visit "/new_unit/unit_info"

        fill_in "unit_name", with: "Troop 456"
        fill_in "location", with: "El Segundo, CA"
        expect { click_on "Next" }.to change { Unit.count }.by(1)
      end

      it "creates a new unit with members" do
        visit "/new_unit/unit_info"

        fill_in "unit_name", with: "Troop 456"
        fill_in "location", with: "El Segundo, CA"
        expect { click_on "Next" }.to change { UnitMembership.count }.by(1)
      end

      it "redirects to the welcome page" do
        visit "/new_unit/unit_info"

        fill_in "unit_name", with: "Troop 456"
        fill_in "location", with: "El Segundo, CA"
        click_on "Next"
        
        expect(page).to have_current_path(unit_welcome_path(Unit.last))
      end
    end

    describe "negative cases" do
      it "fails on empty name" do
        visit "/new_unit/unit_info"

        fill_in "location", with: "El Segundo, CA"
        expect { click_on "Next" }.to change { Unit.count }.by(0)        
      end

      it "fails on empty name" do
        visit "/new_unit/unit_info"

        fill_in "unit_name", with: "F Troop"
        expect { click_on "Next" }.to change { Unit.count }.by(0)        
      end      
    end
  end
end
# rubocop:enable Metrics/BlockLength