FactoryBot.define do
  factory :message_recipient do
    message_receivable_type { "MyString" }
    message_receivable_id { "MyString" }
    message_id { 1 }
  end
end
