FactoryBot.define do
  factory :location do
    name { Faker::Address.community }
    address { Faker::Address.full_address }
    phone { Faker::PhoneNumber.phone_number }
  end
end
