# frozen_string_literal: true

require "rails_helper"

describe "events", type: :feature do
  describe "redirects bogus magic links" do
    # it "when already logged in" do
    #   @member = FactoryBot.create(:member)
    #   login_as(@member, scope: :user)
    #   visit("/bogus")
    #   expect(page).to have_current_path(root_path)
    # end

    it "when not logged in" do
      visit("/bogus")
      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
