FactoryBot.define do
  factory :magic_link do
    token { "MyString" }
    user_id { 1 }
    expires_at { "2021-09-30 07:37:31" }
  end
end
