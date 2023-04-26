# frozen_string_literal: true

# Test creation of an Event
require "rails_helper"
require "rack_session_access/capybara"

# rubocop:disable Metrics/BlockLength
describe "new unit", type: :feature do
  describe "step 1: email" do
    it "accepts an email address" do
      visit "/new_unit/start"

      fill_in "email", with: Faker::Internet.email
      click_on "Next"
      expect(page).to have_current_path("/new_unit/code")
    end

    it "sends a code email" do
      visit "/new_unit/start"

      fill_in "email", with: Faker::Internet.email
      expect { click_on "Next" }.to change { ActionMailer::Base.deliveries.count }.by(1)
      delivery = ActionMailer::Base.deliveries.last
      code = delivery.subject.split(" ").last
    end
  end

  describe "step 2: verify code" do
    it "accepts a valid code" do
      visit "/new_unit/start"
      fill_in "email", with: Faker::Internet.email
      click_on "Next"

      delivery = ActionMailer::Base.deliveries.last
      code = delivery.subject.split(" ").last

      expect(page).to have_current_path("/new_unit/code")
      fill_in "code", with: code
      click_on "Next"
      expect(page).to have_current_path("/new_unit/user_info")
    end

    it "rejects a valid code" do
      visit "/new_unit/start"
      fill_in "email", with: Faker::Internet.email
      click_on "Next"

      delivery = ActionMailer::Base.deliveries.last
      code = delivery.subject.split(" ").last

      expect(page).to have_current_path("/new_unit/code")
      fill_in "code", with: code.reverse
      click_on "Next"
      expect(page).to have_current_path("/new_unit/code")
    end    
  end

  describe "step 3: user details" do
    it "creates new User and Unit records" do
      visit "/new_unit/user_info"

      Faker::Config.locale = "en-US"
      fill_in "first_name", with: first_name = Faker::Name.first_name
      fill_in "last_name", with: last_name = Faker::Name.last_name
      fill_in "nickname", with: nickname = Faker::Name.first_name
      fill_in "phone", with: phone_number = Faker::PhoneNumber.cell_phone
      expect { click_on "Next" }.to change { User.count }.by(1)

      user = User.last
      expect(user.first_name).to eq(first_name)
      expect(user.last_name).to eq(last_name)
      expect(user.nickname).to eq(nickname)
      expect(user.phone).to eq(phone_number.phony_normalized(country_code: "US"))


      expect(page).to have_current_path("/new_unit/unit_info")

      fill_in "unit_name", with: "Troop #{Faker::Number.number(digits: 3)}"
      fill_in "location", with: "#{Faker::Address.city}"
      expect { click_on "Next" }.to change { Unit.count }.by(1)

      unit = Unit.last

      expect(unit.email).to eq("#{unit.name.parameterize}#{unit.location.parameterize}".gsub("-", ""))
      expect(page).to have_current_path(unit_start_path(Unit.last))
    end
  end 
end
# rubocop:enable Metrics/BlockLength