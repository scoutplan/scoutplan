# frozen_string_literal: true

FactoryBot.define do
  factory :location do
    name     { Faker::Address.community }
    map_name { Faker::Address.community }
    address  { Faker::Address.full_address }
    phone    { Faker::PhoneNumber.phone_number }
    website  { Faker::Internet.url }
    unit
  end
end
