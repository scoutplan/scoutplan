# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    title           { "Hiking Trip" }
    association     :unit, factory: :unit_with_members
    starts_at       { 14.days.from_now }
    ends_at         { 15.days.from_now }
    status          { :draft }
    event_category
  end

  trait :requires_rsvp do
    requires_rsvp   { true }
  end

  trait :draft do
    status          { :draft }
  end

  trait :published do
    status          { :published }
  end

  trait :past do
    starts_at       { 15.days.ago }
    ends_at         { 14.days.ago }
  end

  trait :series do
    repeats_until   { 28.days.from_now }
  end
end
