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

    it 'requires a status' do
      expect(FactoryBot.build(:unit_membership, status: nil)).not_to be_valid
    end
  end

  describe 'methods' do
    before do
      @member = FactoryBot.create(:unit_membership)
    end

    it 'includes self in family' do
      expect(@member.family).to include(@member)
    end

    it 'returns a time zone' do
      expect(@member.time_zone).to eq('Eastern Time (US & Canada)')
    end
  end
end
