FactoryBot.define do
  factory :event_rsvp do
    event
    user
    response { 1 }
  end
end
