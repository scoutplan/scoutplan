# frozen_string_literal: true

FactoryBot.define do
  factory :unit_membership,
          aliases: %i[member parent_unit_membership child_unit_membership respondent] do
    unit
    user
    email  { Faker::Internet.email }
    status { "active" }
    role   { "member" }
    member_type { "adult" }

    trait :admin do
      role { "admin" }
    end

    trait :non_admin do
      role { "member" }
    end

    trait :inactive do
      status { "inactive" }
    end

    trait :registered do
      status { "registered" }
    end

    trait :active do
      status { "active" }
    end

    trait :youth do
      member_type { "youth" }
    end

    trait :youth_with_rsvps do
      member_type { "youth" }
      allow_youth_rsvps { true }
    end
  end
end
