FactoryBot.define do
  factory :member_relationship do
    parent_unit_membership factory: :unit_membership
    child_unit_membership { association :unit_membership, unit: parent_unit_membership&.unit }
  end
end
