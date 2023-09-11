FactoryBot.define do
  factory :message do
    association :author, factory: :unit_membership
    send_at { "2022-04-14 14:14:50" }
    title { "MyString" }
    body { "MyText" }
    status { 1 }
  end
end
