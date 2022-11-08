# frozen_string_literal: true

require "rails_helper"

RSpec.describe RsvpToken, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.create(:rsvp_token)).to be_valid
  end

  context 'callbacks' do
    it 'generates a value' do
      expect(FactoryBot.create(:rsvp_token).value).to be_present
    end
  end

  context 'validations' do
    it 'prevents duplicates' do
      token = FactoryBot.create(:rsvp_token)
      expect(FactoryBot.build(:rsvp_token,
                              unit_membership: token.unit_membership,
                              event: token.event)).not_to be_valid
    end
  end
end
