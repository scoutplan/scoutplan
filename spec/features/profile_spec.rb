# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
describe "user profile", type: :feature do
  before :each do
    @member = FactoryBot.create(:member)
    @user = @member.user
    @unit = @member.unit
    @youth_member = FactoryBot.create(:member, :youth, unit: @unit)
    @member.child_relationships.create!(child_unit_membership: @youth_member)
    login_as(@member.user, scope: :user)
  end

  it "includes current user information" do
    path = edit_profile_path(@member)
    visit path
    expect(page).to have_current_path(path)
    expect(page.find("#unit_membership_user_attributes_first_name").value).to eq(@member.first_name)
    expect(page.find("#unit_membership_user_attributes_last_name").value).to eq(@member.last_name)
    expect(page.find("#unit_membership_user_attributes_email").value).to eq(@member.email)

    expect(page.find("#unit_membership_user_attributes_phone").value)
      .to eq(@member.phone.phony_formatted(country_code: "US"))
  end

  describe "editing child member" do
    before do
      path = edit_profile_path(@youth_member)
      visit path
      expect(page).to have_current_path(path)
    end

    it "includes child user information" do
      expect(page.find("#unit_membership_user_attributes_first_name").value).to eq(@youth_member.first_name)
      expect(page.find("#unit_membership_user_attributes_last_name").value).to eq(@youth_member.last_name)
      expect(page.find("#unit_membership_user_attributes_email").value).to eq(@youth_member.email)

      expect(page.find("#unit_membership_user_attributes_phone").value)
        .to eq(@youth_member.phone.phony_formatted(country_code: "US"))
    end

    describe "youth RSVP switch" do
      it "is show if feature enabled for unit" do
        expect(page).to have_content("Allow #{@youth_member.first_name} to RSVP for events")
      end

      it "is hidden if feature disabled for unit" do
        @unit.update(allow_youth_rsvps: false)
        puts @unit.inspect
        path = edit_profile_path(@youth_member)
        visit path
        expect(page).not_to have_content("Allow #{@youth_member.first_name} to RSVP for events")
      end
    end
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
