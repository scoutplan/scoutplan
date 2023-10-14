# frozen_string_literal: true

FactoryBot.define do
  factory :event_rsvp do
    transient do
      unit { create(:unit) }
    end

    event { association :event, unit: unit }
    unit_membership { association :unit_membership, unit: unit }
    respondent { unit_membership }
    response { "declined" }

    trait :accepted do
      response { "accepted" }
    end
  end
end
