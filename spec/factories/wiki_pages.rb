FactoryBot.define do
  factory :wiki_page do
    unit_id { 1 }
    visibility { "MyString" }
    body { "MyText" }
  end
end
