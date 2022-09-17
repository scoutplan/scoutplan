FactoryBot.define do
  factory :location do
    name { Faker::Address.community }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    postal_code { Faker::Address.zip }
    phone { Faker::PhoneNumber.phone_number }
    locatable_id { 1 }
    locatable_type { "Event" }
    key { "departure" }
  end
end
