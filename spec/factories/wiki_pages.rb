FactoryBot.define do
  factory :wiki_page do
    unit_id { 1 }
    visibility { "anyone" }
    title { "MyString" }
    body { "MyText" }
    unit
  end
end
