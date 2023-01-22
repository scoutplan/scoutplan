# frozen_string_literal: true

describe "the sign-in process", type: :feature do
  before do
    skip "needs to be fixed"
    @user = FactoryBot.create(:user, email: "test@scoutplan.org")
    @unit = FactoryBot.create(:unit)
    @membership = @unit.unit_memberships.create(user: @user, status: :active, role: "member")
  end

  it "signs in and redirects" do
    visit new_user_session_path
    save_and_open_page
    fill_in "user_email", with: @user.email
    fill_in "user_password", with: "password"
    click_button I18n.t("global.sign_in")
    expect(page).to have_current_path(list_unit_events_path(@unit))
  end
end
