# frozen_string_literal: true

require "rails_helper"

describe "My RSVPs", type: :feature do
  before do
    @admin = FactoryBot.create(:unit_membership, :admin)
    @unit = @admin.unit
    login_as(@admin.user, scope: :user)
  end

  it "visits the My RSVPs page" do
    path = unit_my_rsvps_path(@unit)
    visit path
    expect(page).to have_current_path(path)
  end
end
