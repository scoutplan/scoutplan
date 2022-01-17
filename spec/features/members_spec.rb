# frozen_string_literal: true

require "rails_helper"

describe "unit_memberships", type: :feature do
  before do
    User.destroy_all
    @admin = FactoryBot.create(:unit_membership, :admin)
    login_as(@admin.user, scope: :user)
  end

  it "visits the members page" do
    path = unit_members_path(@admin.unit)
    visit path
    expect(page).to have_current_path(path)
  end

  it "visits a member", js: true do
    User.destroy_all
    member = FactoryBot.create(:unit_membership, unit: @admin.unit)
    visit member_path(member)
  end
end
