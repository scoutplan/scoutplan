# frozen_string_literal: true

FactoryBot.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :user, aliases: %i[parent child] do
    email
    password { 'password' }
  end
end
