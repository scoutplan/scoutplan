FactoryBot.define do
  factory :event_activity do
    event
    position { 1 }
    sequence :title do |n|
      "Activity #{n}"
    end
  end
end
