FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "person#{n}@scoutplan.org" }
    password { 'password' }
  end
end
