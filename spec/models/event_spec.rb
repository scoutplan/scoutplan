# frozen_string_literal: true

require "rails_helper"

RSpec.describe Event, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.build(:event)).to be_valid
  end

  context "validations" do
    it "requires a title" do
      expect(FactoryBot.build(:event, title: nil)).not_to be_valid
    end

    it "requires a unit" do
      expect(FactoryBot.build(:event, unit: nil)).not_to be_valid
    end
  end

  describe "methods" do
    it "is past when end date is before now" do
      expect(FactoryBot.build(:event, :past).past?).to be_truthy
    end

    it "is not past when end date after now" do
      expect(FactoryBot.build(:event).past?).to be_falsey
    end

    it "has a valid RSVP closes_at value" do
      event = FactoryBot.build(:event)
      expect(event.rsvp_closes_at).to eq(event.starts_at)
    end

    describe "rsvp_open?" do
      it "RSVP is open if rsvp_closes_at is nil and start date hasn't occurred yet" do
        event = FactoryBot.build(:event, :requires_rsvp, :published, starts_at: 5.days.from_now, rsvp_closes_at: nil)
        expect(event.rsvp_open?).to be_truthy
      end

      it "RSVP is open if rsvp_closes_at hasn't occurred yet" do
        event = FactoryBot.build(:event, :requires_rsvp, :published, starts_at: 5.days.from_now, rsvp_closes_at: 4.days.from_now)
        expect(event.rsvp_open?).to be_truthy
      end

      it "RSVP is closed if rsvp_closes_at has passed but starts_at hasn't" do
        event = FactoryBot.build(:event, :requires_rsvp, starts_at: 5.days.from_now, rsvp_closes_at: 2.days.ago)
        expect(event.rsvp_open?).to be_falsey
      end

      it "RSVP is closed if rsvp_closes_at is nil and start_date has passed" do
        event = FactoryBot.build(:event, :requires_rsvp, starts_at: 5.days.ago, rsvp_closes_at: nil)
        expect(event.rsvp_open?).to be_falsey
      end

      it "RSVP is closed if RSVP isn't required" do
        event = FactoryBot.build(:event, requires_rsvp: false, starts_at: 5.days.ago, rsvp_closes_at: nil)
        expect(event.rsvp_open?).to be_falsey
      end
    end
  end

  describe "extensions" do
    describe "date and time attributes" do
      it "works" do
        event = FactoryBot.build(:event)
        puts event.starts_at.class.name
        expect(event.starts_at).to be_a(ActiveSupport::TimeWithZone)
        expect(event.starts_at_date).to be_a(Date)
      end
    end
  end

  describe "rsvps" do
    before do
      @member = FactoryBot.create(:member, :non_admin)
      @event = FactoryBot.create(:event, unit: @member.unit)
      @rsvp_token = @event.rsvp_tokens.create(member: @member)
      @rsvp = @event.rsvps.create(member: @member, response: :declined, respondent: @member)
    end

    it "finds the rsvp for a member" do
      expect(@event.rsvp_for(@member)).to eq @rsvp
    end

    it "finds the rsvp token for a member" do
      expect(@event.rsvp_token_for(@member)).to eq(@rsvp_token)
    end
  end

  describe "scopes" do
    describe "imminent" do
      it "exludes same-day events in the PM" do
        Timecop.freeze(DateTime.now.change({ hour: 19, minute: 0 }))
        event = FactoryBot.create(:event, starts_at: DateTime.now.change({ hour: 16, minute: 0 }))
        expect(Event.imminent).not_to include(event)
      end
    end
  end
end
