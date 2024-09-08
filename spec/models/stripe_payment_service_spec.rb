require "rails_helper"

RSpec.describe StripePaymentService, type: :model do
  it "calculates the transaction fee" do
    unit = FactoryBot.create(:unit)
    PaymentAccount.create(unit: unit, account_id: "acct_12345", transaction_fees_covered_by: "member")
    service = StripePaymentService.new(unit)
    expect(service.member_transaction_fee(40.00)).to eq(1.50)
  end
end
