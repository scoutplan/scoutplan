require 'rails_helper'

RSpec.describe Payment, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.build(:payment)).to be_valid
  end
end
