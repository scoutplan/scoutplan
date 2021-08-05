require 'rails_helper'

RSpec.describe Event, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.build(:event)).to be_valid
  end

  context 'Validations' do
    it 'requires a title' do
      expect(FactoryBot.build(:event, title: nil)).not_to be_valid
    end
  end
end
