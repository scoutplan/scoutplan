# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventRsvp, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:event_rsvp)).to be_valid
  end

  describe 'validations' do
    it 'prevents duplicates' do
      rsvp = FactoryBot.create(:event_rsvp)
      dupe = FactoryBot.build(:event_rsvp, unit_membership_id: rsvp.unit_membership_id, event_id: rsvp.event_id)
      expect(dupe).not_to be_valid
    end

    it 'prevents mismatched Unit associations' do
      member = FactoryBot.create(:unit_membership)
      event = FactoryBot.create(:event)

      # member and event should belong to different Units at this point
      expect(member.unit).not_to eq(event.unit)

      rsvp = EventRsvp.new(event: event, member: member, respondent: member, response: :declined)
      expect(rsvp).not_to be_valid
    end
  end
end
