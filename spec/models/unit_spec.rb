require 'rails_helper'

RSpec.describe Unit, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.build(:unit)).to be_valid
  end

  context 'callbacks' do
    it 'creates default categories' do
      EventCategory.create(name: 'Troop Meeting')
      EventCategory.create(name: 'Camping')
      EventCategory.create(name: 'Court of Honor')

      unit = Unit.create(name: 'Troop 1234')

      # unit = FactoryBot.create(:unit)
      expect(unit.event_categories.count).to eq(3)
    end
  end

  context 'validations' do
    it 'requires a name' do
      expect(FactoryBot.build(:unit, name: nil)).not_to be_valid
    end
  end

  context 'methods' do
    it 'finds a membership for a user' do
      membership = FactoryBot.create(:unit_membership)
      unit = membership.unit
      user = membership.user
      expect(unit.membership_for(user)).to eq(membership)
    end
  end
end
