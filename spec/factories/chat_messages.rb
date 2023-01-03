FactoryBot.define do
  factory :chat_message do
    chat_id { 1 }
    author_id { 1 }
    message { "MyString" }
  end
end
