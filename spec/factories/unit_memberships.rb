# frozen_string_literal: true

FactoryBot.define do
  factory :unit_membership,
          aliases: %i[member parent_member child_member respondent] do
    unit
    user
    status { "active" }
    role   { "member" }
    member_type { "adult" }

    trait :admin do
      role { "admin" }
    end

    trait :non_admin do
      role { "member" }
    end
  end
end
