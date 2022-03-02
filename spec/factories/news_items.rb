FactoryBot.define do
  factory :news_item do
    unit
    title { Faker::ChuckNorris.fact }
    body { Faker::Lorem.paragraph(sentence_count: 2, supplemental: true, random_sentences_to_add: 2) }
    status { "draft" }
  end
end
