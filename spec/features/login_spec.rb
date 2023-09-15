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

  it "send a magic link" do
    visit new_user_session_path
    fill_in "user_email", with: @user.email
    expect { click_button I18n.t("global.sign_in_with_email") }.to change { MagicLink.count }.by(1)
    # expect { click_button I18n.t("global.sign_in_with_email") }.to change { ActionMailer::Base.deliveries.count }.by(1)
    expect(page).to have_current_path(new_user_session_path)

    visit(magic_link_path(MagicLink.last.token))
    expect(page).to have_current_path(list_unit_events_path(@unit))
  end
end
