require 'rails_helper'

RSpec.describe Unit, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.build(:unit)).to be_valid
  end

  context 'Validations' do
    it 'requires a name' do
      expect(FactoryBot.build(:unit, name: nil)).not_to be_valid
    end
  end
end
