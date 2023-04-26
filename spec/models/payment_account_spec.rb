require 'rails_helper'

RSpec.describe PaymentAccount, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.build(:payment_account)).to be_valid
  end
end
