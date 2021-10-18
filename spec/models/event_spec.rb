# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:event)).to be_valid
  end

  context 'validations' do
    it 'requires a title' do
      expect(FactoryBot.build(:event, title: nil)).not_to be_valid
    end

    it 'requires a unit' do
      expect(FactoryBot.build(:event, unit: nil)).not_to be_valid
    end
  end

  describe 'methods' do
    it 'is past when end date is before now' do
      expect(FactoryBot.build(:event, :past).past?).to be_truthy
    end

    it 'is not past when end date after now' do
      expect(FactoryBot.build(:event).past?).to be_falsey
    end

    it 'has a valid RSVP closes_at value' do
      event = FactoryBot.build(:event)
      expect(event.rsvp_closes_at).to eq(event.starts_at)
    end
  end

  describe 'rsvps' do
    before do
      @member = FactoryBot.create(:member, :non_admin)
      @event = FactoryBot.create(:event, unit: @member.unit)
      @rsvp_token = @event.rsvp_tokens.create(member: @member)
      @rsvp = @event.rsvps.create(member: @member, response: :declined)
    end

    it 'finds the rsvp for a member' do
      expect(@event.rsvp_for(@member)).to eq @rsvp
    end

    it 'finds the rsvp token for a member' do
      expect(@event.rsvp_token_for(@member)).to eq(@rsvp_token)
    end
  end

  describe 'series' do
    it 'callback fires' do
      expect { FactoryBot.create(:event, :series) }.to change { Event.count }.by(3)
    end

    it 'finds event children' do
      event = FactoryBot.create(:event, :series)
      expect(event.series_children.count).to eq(2)
    end

    it 'finds its series siblings' do
      event = FactoryBot.create(:event, :series)
      child_event = event.series_children.first
      expect(child_event.series_siblings.count).to eq(2)
    end
  end
end
