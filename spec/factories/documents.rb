FactoryBot.define do
  factory :document do
    documentable_type { "MyString" }
    documentable_id { 1 }
  end
end
