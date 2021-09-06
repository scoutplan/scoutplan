FactoryBot.define do
  factory :unit do
    name     { 'Troop 231' }
    location { 'Peoria, IL' }
  end

  factory :unit_with_members, parent: :unit do |unit|
    memberships { create_list :unit_membership, 3 }
  end
end
