# frozen_string_literal: true

require "rails_helper"

describe "events", type: :feature do
  before do
    @admin = FactoryBot.create(:unit_membership, :admin)
    @unit = @admin.unit
    login_as(@admin.user, scope: :user)
  end

  describe "create" do
    it "creates a member" do
      visit new_unit_unit_membership_path(@unit)
      expect(page).to have_current_path(new_unit_unit_membership_path(@unit))

      fill_in "First name", with: "John"
      fill_in "Last name", with: "Doe"
      fill_in "Email", with: "john.doe@doefamily.org"
      fill_in "Phone", with: "555-555-5555"

      click_button "Add Member", disabled: true

      expect(UnitMembership.last.email).to eq("john.doe@doefamily.org")
    end

    it "creates a member when user exists" do
      email = "john@doefamily.org"
      FactoryBot.create(:user, email: email)

      visit new_unit_unit_membership_path(@unit)
      expect(page).to have_current_path(new_unit_unit_membership_path(@unit))

      fill_in "First name", with: "John"
      fill_in "Last name", with: "Doe"
      fill_in "Email", with: email
      fill_in "Phone", with: "555-555-5555"

      click_button "Add Member", disabled: true

      expect(UnitMembership.last.email).to eq(email)
    end
  end
end
