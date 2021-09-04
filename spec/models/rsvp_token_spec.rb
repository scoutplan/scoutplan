require 'rails_helper'

RSpec.describe RsvpToken, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.create(:rsvp_token)).to be_valid
  end

  context 'callbacks' do
    it 'generates a value' do
      expect(FactoryBot.create(:rsvp_token).value).to be_present
    end
  end
end
