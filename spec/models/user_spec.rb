require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'factories' do
    it 'has a valid factory' do
      expect(FactoryBot.build(:user)).to be_valid
    end
  end
end
