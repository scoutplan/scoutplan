# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
FactoryBot.define do
  factory :event do
    title       { "Hiking Trip" }
    association :unit, factory: :unit_with_members
    starts_at   { 14.days.from_now }
    ends_at     { 15.days.from_now }
    status      { :draft }
    event_category

    after(:create) do |event, _evaluator|
      l = create(:location, unit: event.unit)
      create(:event_location, event: event, location: l, location_type: :arrival)
    end
  end

  trait :with_location do
    location { Faker::Address.community }
  end

  trait :with_address do
    address { Faker::Address.street_address }
  end

  trait :requires_rsvp do
    requires_rsvp { true }
    status { :published }
    rsvp_closes_at { 13.day.from_now }
  end

  trait :draft do
    status { :draft }
  end

  trait :published do
    status { :published }
  end

  trait :past do
    starts_at { 15.days.ago }
    ends_at { 14.days.ago }
  end

  trait :series do
    repeats_until { 28.days.from_now }
  end
end
# rubocop:enable Metrics/BlockLength
