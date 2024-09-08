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
      @payment = FactoryBot.create(:payment, event: @event, unit_membership: @member, amount: 10_000)
    end
  end
end
