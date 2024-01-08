# frozen_string_literal: true

require "rails_helper"

describe "password prompt", type: :feature do
  before do
    @member = FactoryBot.create(:unit_membership)
    @user = @member.user
    @unit = @member.unit
    @magic_link = MagicLink.generate_link(@member, root_path, 1.hour)
  end

  it "displays the password prompt when logging in via magic link" do
    visit magic_link_url(token: @magic_link.token)
    expect(page).to have_current_path(list_unit_events_path(@unit))
    expect(page).to have_content("it looks like you signed in via an email link")
    click_on "Let's set a password now"
    expect(page).to have_current_path(profile_change_password_path(@member))
  end

  it "doesn't display the password prompt the user has a password set" do
    @member.user.update(password_changed_at: 4.days.ago)
    visit magic_link_url(token: @magic_link.token)
    expect(page).to have_current_path(list_unit_events_path(@unit))
    expect(page).not_to have_content("it looks like you signed in via an email link")
  end

  it "doesn't display the password prompt when logging in via password" do
    login_as(@member.user, scope: :user)
    visit(root_path)
    expect(page).to have_current_path(list_unit_events_path(@unit))
    expect(page).not_to have_content("it looks like you signed in via an email link")
  end

  it "doesn't display the password prompt when dismiss cookie is set", js: true do
    page.driver.set_cookie("password_prompt_dismissed", "true", {})
    visit magic_link_path(token: @magic_link.token)
    expect(page).to have_current_path(list_unit_events_path(@unit))
    expect(page).not_to have_content("it looks like you signed in via an email link")
  end

  it "updates the password_changed_at timestamp when the user sets a password" do
    expect(@user.password_set?).to be_falsey
    login_as(@member.user, scope: :user)
    visit profile_change_password_path(@member)
    fill_in "Password", with: "newpassword"
    fill_in "Password confirmation", with: "newpassword"
    click_on "Change password"
    @user.reload
    expect(@user.password_set?).to be_truthy
  end
end
