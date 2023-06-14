require "rails_helper"

RSpec.describe Payment, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.build(:payment)).to be_valid
  end

  describe "transaction fee" do
    before do
      @member = FactoryBot.create(:unit_membership)
      @unit = @member.unit
      FactoryBot.create(:payment_account, unit: @unit)
      @event = FactoryBot.create(:event, unit: @unit)
      @payment = FactoryBot.create(:payment, event: @event, unit_membership: @member, amount: 10000)
    end

    it "returns 0 for non-stripe payments" do
      @payment.method = "cash"
      expect(@payment.transaction_fee).to eq(0)
    end

    it "returns the correct amount for stripe payments" do
      @payment.method = "stripe"
      expect(@payment.transaction_fee).to eq(320)
    end

    it "returns 0 when unit covers transaction fees" do
      @payment.method = "stripe"
      @unit.payment_account.transaction_fees_covered_by = "unit"
      expect(@payment.transaction_fee).to eq(0)
    end

    it "returns 50% when unit covers 50% of transaction fees" do
      @payment.method = "stripe"
      @unit.payment_account.update(transaction_fees_covered_by: "split_50_50")
      expect(@payment.transaction_fee).to eq(160)
    end
  end
end
