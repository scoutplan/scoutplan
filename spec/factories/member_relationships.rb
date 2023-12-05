FactoryBot.define do
  factory :member_relationship do
    parent_member factory: :unit_membership
    child_member { association :unit_membership, unit: parent_member&.unit }
  end
end
