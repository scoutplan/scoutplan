# frozen_string_literal: true

FactoryBot.define do
  factory :rsvp_token do
    member
    event

    after(:create) do |rsvp_token|
      rsvp_token.member.unit = rsvp_token.event.unit
    end
  end
end
