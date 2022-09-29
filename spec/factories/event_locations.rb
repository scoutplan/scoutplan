# frozen_string_literal: true

FactoryBot.define do
  factory :event_location do
    event
    location
    location_type { "test" }
  end
end
