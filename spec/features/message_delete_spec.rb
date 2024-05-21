# frozen_string_literal: true

require "rails_helper"

describe "messages", type: :feature do
  before do
    @member = FactoryBot.create(:member, :admin)
    @unit = @member.unit
    @second_member = FactoryBot.create(:member, member_type: "adult", unit: @unit,
      first_name: "Mortimer", last_name: "Snerd")
    @third_member = FactoryBot.create(:member, member_type: "adult", unit: @unit,
      first_name: "Mathilda", last_name: "Snerd")
    @fourth_member = FactoryBot.create(:member, member_type: "youth", unit: @unit,
      first_name: "Murgatroyd", last_name: "Snerd")
    @fifth_member = FactoryBot.create(:member, member_type: "youth", unit: @unit,
      first_name: "Matt", last_name: "Snerd")
    @family = User.where(last_name: "Snerd").order(:first_name)

    MemberRelationship.create(parent_unit_membership: @second_member, child_unit_membership: @fourth_member)
    MemberRelationship.create(parent_unit_membership: @third_member, child_unit_membership: @fourth_member)

    @event = FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit,
      starts_at: 7.days.from_now, ends_at: 8.days.from_now, rsvp_closes_at: 6.days.from_now)

    @event.rsvps.create!(unit_membership: @second_member, response: :accepted, respondent: @second_member)

    login_as(@member.user, scope: :user)
    Flipper.enable(:messages)
  end

  describe "message deletion", js: true do
    it "redirects to drafts page" do
      skip "failing inconsistently out of the blue"
      @message = FactoryBot.create(:message, :draft_message, unit: @unit)
      visit edit_unit_message_path(@unit, @message)
      expect(page).to have_css("#delete_draft_link", visible: false)
      count = Message.count
      accept_prompt do
        find("#delete_draft_link", visible: false).click
      end
      expect(page).to have_current_path(drafts_unit_messages_path(@unit))
      expect(Message.count).to eq(count - 1)
    end
  end
end
