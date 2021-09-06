FactoryBot.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :user, aliases: [:parent, :child] do
    email
    password { 'password' }
  end
end
