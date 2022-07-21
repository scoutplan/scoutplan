FactoryBot.define do
  factory :document_type do
    documentable_type { "MyString" }
    documentable_id { 1 }
    description { "MyString" }
    required { false }
  end
end
