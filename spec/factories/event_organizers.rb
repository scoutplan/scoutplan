FactoryBot.define do
  factory :event_organizer do
    event_id { 1 }
    unit_membership_id { 1 }
    assigned_by_id { 1 }
    role { "organizer" }
  end
end
