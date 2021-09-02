FactoryBot.define do
  factory :rsvp_token do
    user_id { 1 }
    event_id { 1 }
    value { "MyString" }
    expires_at { "2021-09-02 12:45:25" }
  end
end
