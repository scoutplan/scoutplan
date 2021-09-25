FactoryBot.define do
  factory :member_relationship do
    parent_member factory: :unit_membership
    child_member  factory: :unit_membership
  end
end
