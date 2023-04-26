require 'rails_helper'

RSpec.describe PackingList, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.build(:packing_list)).to be_valid
  end
end
