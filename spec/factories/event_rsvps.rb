FactoryBot.define do
  factory :event_rsvp do
    event
    user
    response { 'declined' }

    trait :accepted do
      response { 'accepted' }
    end
  end
end
