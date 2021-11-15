# frozen_string_literal: true

FactoryBot.define do
  factory :unit_membership do
    unit
    user
    status { 'active' }
    role   { 'member' }
    member_type { 'adult' }

    trait :admin do
      role { 'admin' }
    end

    trait :non_admin do
      role { '' }
    end
  end

  factory :member, parent: :unit_membership do
  end

  factory :parent_member, parent: :unit_membership do
  end

  factory :child_member, parent: :unit_membership do
  end

  factory :respondent, parent: :unit_membership do
  end
end
