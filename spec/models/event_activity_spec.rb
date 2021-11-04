require 'rails_helper'

RSpec.describe EventActivity, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:event_activity)).to be_valid
  end

  describe 'validations' do
    it 'requires an event' do
      expect(FactoryBot.build(:event_activity, event: nil)).not_to be_valid
    end
  end
end
