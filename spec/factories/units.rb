FactoryBot.define do
  factory :unit do
    name     { 'Troop 231' }
    location { 'Peoria, IL' }

    after(:create) do |unit, evaluator|
      ['Troop Meeting', 'Camping Trip', 'Hike', 'Service Project'].each do |category_name|
        unit.event_categories.create(name: category_name)
      end
    end
  end

  factory :unit_with_members, parent: :unit do |unit|
    memberships { create_list :unit_membership, 3 }
  end
end
