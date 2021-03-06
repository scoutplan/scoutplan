# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
describe "planner", type: :feature do
  before :each do
    @member = FactoryBot.create(:member)
    @user = @member.user
    login_as(@user, scope: :user)
  end

  it "includes current user information" do
    visit edit_profile_path
    expect(page).to have_current_path(edit_profile_path)
    expect(page.find("#user_first_name").value).to eq(@user.first_name)
    expect(page.find("#user_last_name").value).to eq(@user.last_name)
    expect(page.find("#user_email").value).to eq(@user.email)
    expect(page.find("#user_phone").value).to eq(@user.phone)
  end

  it "changes stuff" do
    visit edit_profile_path

    new_first_name = Faker::Name.first_name
    new_last_name = Faker::Name.last_name
    new_email = Faker::Internet.email
    new_phone = Faker::PhoneNumber.phone_number
    new_nickname = Faker::FunnyName.name

    fill_in :user_first_name, with: new_first_name
    fill_in :user_last_name, with: new_last_name
    fill_in :user_nickname, with: new_nickname
    fill_in :user_email, with: new_email
    fill_in :user_phone, with: new_phone
    click_button "Save Changes"

    @user.reload
    expect(@user.first_name).to eq(new_first_name)
    expect(@user.last_name).to eq(new_last_name)
    expect(@user.nickname).to eq(new_nickname)
    expect(@user.email).to eq(new_email)
    expect(@user.phone).to eq(new_phone)
  end
end
