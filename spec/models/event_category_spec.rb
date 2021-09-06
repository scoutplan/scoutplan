require 'rails_helper'

RSpec.describe EventCategory, type: :model do
  describe 'validations' do
    it 'prevents duplicate names' do
      cat = FactoryBot.create(:event_category)
      dupe = FactoryBot.build(:event_category, unit: cat.unit)

      expect(dupe).not_to be_valid
    end

    it 'allows same name across units' do
      cat = FactoryBot.create(:event_category)
      new_unit = FactoryBot.create(:unit)
      expect(FactoryBot.build(:event_category, unit: new_unit)).to be_valid
    end
  end
end
