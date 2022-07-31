# frozen_string_literal: true

require "rails_helper"

describe "messages", type: :feature do
  before do
    @admin = FactoryBot.create(:unit_membership, :admin)
    @unit = @admin.unit
    login_as(@admin.user, scope: :user)
  end

  it "saves previews as drafts" do
    visit new_unit_message_path(@unit)
    fill_in "message_title", with: "Test Message"
    # click_link_or_button "Send Preview"
    expect { click_link_or_button "Send Preview" }.to change { Message.draft.count }.by 1
  end
end
