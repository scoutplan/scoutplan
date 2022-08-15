# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
describe "unit_memberships", type: :feature do
  before do
    User.destroy_all
    @admin = FactoryBot.create(:unit_membership, :admin)
    @unit = @admin.unit
    login_as(@admin.user, scope: :user)
  end

  it "visits the members page" do
    path = unit_members_path(@unit)
    visit path
    expect(page).to have_current_path(path)
  end

  it "visits a member" do
    member = FactoryBot.create(:unit_membership, unit: @unit)
    visit unit_member_path(@unit, member)
    expect(page).to have_current_path unit_member_path(@unit, member)
  end

  it "creates a member" do
    visit unit_members_path(@unit)
    click_link_or_button I18n.t("members.index.new_button_caption")

    # fill in the new member form
    fill_in "unit_membership_user_attributes_first_name", with: Faker::Name.first_name
    fill_in "unit_membership_user_attributes_last_name", with: Faker::Name.last_name
    fill_in "unit_membership_user_attributes_nickname", with: Faker::Name.first_name
    fill_in "unit_membership_user_attributes_email", with: Faker::Internet.email
    fill_in "unit_membership_user_attributes_phone", with: Faker::PhoneNumber.phone_number
    choose "unit_membership_member_type_youth"
    choose "unit_membership_status_active"
    check "settings_communication_via_email"
    check "settings_communication_via_sms"

    # click the button
    expect { click_link_or_button "Add This Member" }.to change { UnitMembership.all.count }.by 1
    expect(page).to have_current_path unit_members_path(@unit)

    # fetch the newly-created member
    member = UnitMembership.last

    # flash message
    # expect(page).to have_content(I18n.t("members.confirmations.create", member_name: member.full_display_name, unit_name: @unit.name))
  end

  it "creates a member without email and phone" do
    visit unit_members_path(@unit)
    click_link_or_button I18n.t("members.index.new_button_caption")

    # fill in the new member form
    fill_in "unit_membership_user_attributes_first_name", with: Faker::Name.first_name
    fill_in "unit_membership_user_attributes_last_name", with: Faker::Name.last_name
    fill_in "unit_membership_user_attributes_nickname", with: Faker::Name.first_name
    choose "unit_membership_member_type_youth"
    choose "unit_membership_status_active"
    check "settings_communication_via_email"
    check "settings_communication_via_sms"

    # click the button
    expect { click_link_or_button "Add This Member" }.to change { UnitMembership.all.count }.by 1
    expect(page).to have_current_path unit_members_path(@unit)

    # fetch the newly-created member
    member = UnitMembership.last
    # expect(member.anonymous_email?).to be_truthy

    # flash message
    # expect(page).to have_content(I18n.t("members.confirmations.create", member_name: member.full_display_name, unit_name: @unit.name))
  end

  it "creates a member with an existing user" do
    member = FactoryBot.create(:member)

    visit unit_members_path(@unit)
    click_link_or_button I18n.t("members.index.new_button_caption")

    # fill in the new member form
    fill_in "unit_membership_user_attributes_first_name", with: member.first_name
    fill_in "unit_membership_user_attributes_last_name", with: member.last_name
    fill_in "unit_membership_user_attributes_nickname", with: member.first_name
    fill_in "unit_membership_user_attributes_email", with: member.email
    choose "unit_membership_member_type_youth"
    choose "unit_membership_status_active"
    check "settings_communication_via_email"
    check "settings_communication_via_sms"

    # click the button
    expect { click_link_or_button "Add This Member" }.to change { UnitMembership.all.count }.by 1
    expect(page).to have_current_path unit_members_path(@unit)
  end

  it "edits a member's user attributes" do
    member = FactoryBot.create(:member, unit: @admin.unit)
    visit edit_unit_member_path(@unit, member)

    new_name = "A different name"
    fill_in "unit_membership_user_attributes_first_name", with: new_name
    click_link_or_button "Save These Changes"
    member.reload
    expect(member.first_name).to eq(new_name)
  end
end
# rubocop:enable Metrics/BlockLength
