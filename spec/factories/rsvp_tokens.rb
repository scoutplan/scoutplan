# frozen_string_literal: true

FactoryBot.define do
  factory :rsvp_token do
    user
    event
  end
end
