FactoryBot.define do
  factory :user, aliases: [:parent, :child] do
    sequence(:email) { |n| "person#{n}@scoutplan.org" }
    password { 'password' }
  end
end
