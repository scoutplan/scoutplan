# frozen_string_literal: true

require "rails_helper"

describe "the sign-in process", type: :feature do
  before do
    # skip "needs to be fixed"
    # @user = FactoryBot.create(:user, email: "test@scoutplan.org")
    # @unit = FactoryBot.create(:unit)
    # @membership = @unit.unit_memberships.create(user: @user, status: :active, role: "member")
    @member = FactoryBot.create(:unit_membership)
    @user = @member.user
    @unit = @member.unit
  end

  it "signs in and redirects" do
    visit new_user_session_path
    fill_in "user_email", with: @user.email
    click_button "Sign in with email"
    expect(page).to have_current_path(new_user_session_path)

    code = MagicLink.last.login_code
    fill_in "login_code", with: code
    page.find("#submit").click

    expect(page).to have_current_path(list_unit_events_path(@unit))
  end

  it "bounces on bad code" do
    visit new_user_session_path
    fill_in "user_email", with: @user.email
    click_button "Sign in with email"
    expect(page).to have_current_path(new_user_session_path)

    code = MagicLink.last.login_code
    fill_in "login_code", with: "bogus"
    page.find("#submit").click

    expect(page).not_to have_current_path(list_unit_events_path(@unit))
  end
end
