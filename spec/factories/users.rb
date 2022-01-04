# frozen_string_literal: true

FactoryBot.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :user do
    first_name  { "Scoutbert" }
    nickname    { "Scouty" }
    last_name   { "McScouterson" }
    phone       { "+19195551212" }
    password    { "password" }
    email
    type { 0 }
  end

  factory :adult, parent: :user, aliases: [:parent]
  factory :youth, parent: :user, aliases: [:child]
end
