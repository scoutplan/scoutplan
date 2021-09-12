# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnitMembership, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:unit_membership)).to be_valid
  end

  describe 'validations' do
    it 'prevents duplicates' do
      example = FactoryBot.create(:unit_membership)
      expect(FactoryBot.build(:unit_membership, unit: example.unit, user: example.user)).not_to be_valid
    end
  end
end
