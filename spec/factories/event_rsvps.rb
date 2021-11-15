# frozen_string_literal: true

FactoryBot.define do
  factory :event_rsvp do
    event
    member
    respondent
    response { 'declined' }

    trait :accepted do
      response { 'accepted' }
    end
  end
end
