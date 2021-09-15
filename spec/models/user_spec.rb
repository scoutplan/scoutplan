# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.create(:user)).to be_valid
  end

  describe 'methods' do
    before do
      @user = FactoryBot.create(:user)
    end

    it 'includes self in family' do
      expect(@user.family).to include(@user)
    end
  end

  describe 'validations' do
    it 'requires a type' do
      expect(FactoryBot.build(:user, type: nil)).not_to be_valid
    end
  end
end
