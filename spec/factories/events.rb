FactoryBot.define do
  factory :event do
    title    { 'Hiking Trip' }
    unit
    event_category
    starts_at { 14.days.from_now }
    ends_at { 15.days.from_now }
  end
end
