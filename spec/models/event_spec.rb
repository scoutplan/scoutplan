require 'rails_helper'

RSpec.describe Event, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.build(:event)).to be_valid
  end

  context 'validations' do
    it 'requires a title' do
      expect(FactoryBot.build(:event, title: nil)).not_to be_valid
    end

    it 'requires a unit' do
      expect(FactoryBot.build(:event, unit: nil)).not_to be_valid
    end
  end

  context 'methods' do
    it 'is past when end date is before now' do
      expect(FactoryBot.build(:event, :past).past?).to be_truthy
    end

    it 'is not past when end date after now' do
      expect(FactoryBot.build(:event).past?).to be_falsey
    end
  end
end
