# frozen_string_literal: true

FactoryBot.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :user, class: 'Adult' do
    email
    password { 'password' }
  end

  factory :adult, class: 'Adult', parent: :user, aliases: [:parent]

  factory :youth, class: 'Youth', parent: :user, aliases: [:child]
end
