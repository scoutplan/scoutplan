FactoryBot.define do
  factory :message do
    association :author, factory: :unit_membership
    association :sender, factory: :unit_membership
    send_at { "2022-04-14 14:14:50" }
    title { "MyString" }
    body { "<div>MyText</div>" }
    status { 1 }
  end

  trait :draft_message do
    status { "draft" }
  end
end
