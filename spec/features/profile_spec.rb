# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
describe "user profile", type: :feature do
  before :each do
    @member = FactoryBot.create(:member)
    @profile = UnitMembershipProfile.new(@member)
    @user = @member.user
    login_as(@user, scope: :user)
  end

  it "includes current user information" do
    path = edit_profile_path(@member)
    visit path
    expect(page).to have_current_path(path)
    expect(page.find("#unit_membership_user_attributes_first_name").value).to eq(@user.first_name)
    expect(page.find("#unit_membership_user_attributes_last_name").value).to eq(@user.last_name)
    expect(page.find("#unit_membership_user_attributes_email").value).to eq(@user.email)
    expect(page.find("#unit_membership_user_attributes_phone").value).to eq(@user.phone.phony_formatted(country_code: "US"))
  end

  it "changes stuff" do
    path = edit_profile_path(@member)
    visit path

    new_first_name = Faker::Name.first_name
    new_last_name = Faker::Name.last_name
    new_email = Faker::Internet.email
    new_phone = Faker::PhoneNumber.phone_number

    fill_in :unit_membership_user_attributes_first_name, with: new_first_name
    fill_in :unit_membership_user_attributes_last_name, with: new_last_name
    fill_in :unit_membership_user_attributes_email, with: new_email
    fill_in :unit_membership_user_attributes_phone, with: new_phone

    check "settings_communication_via_email", allow_label_click: true, visible: false
    uncheck "settings_communication_via_sms", allow_label_click: true, visible: false

    click_button "Save Changes"

    @member.reload
    @user.reload

    expect(@user.first_name).to eq(new_first_name)
    expect(@user.last_name).to eq(new_last_name)
    expect(@user.email).to eq(new_email)
    expect(@user.phone).to eq(new_phone.phony_normalized(country_code: "US"))

    expect(@member.settings(:communication).via_email).to eq("true")
    expect(@member.settings(:communication).via_sms).to eq("false")
  end
end
# rubocop:enable Metrics/BlockLength
