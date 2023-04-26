FactoryBot.define do
  factory :payment do
    unit_membership
    event
    amount { 1 }
  end
end
