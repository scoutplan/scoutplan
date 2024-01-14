require "rails_helper"

RSpec.describe Event, type: :model do
  describe "methods" do
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
        event = FactoryBot.build(:event, :requires_rsvp, starts_at: 5.days.from_now, ends_at: 6.days.from_now, rsvp_closes_at: 4.days.ago)
        # event = FactoryBot.build(:event, :published, :requires_rsvp)
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

      it "is true when rsvp_opens_at is nil" do
        event = FactoryBot.build(:event, :requires_rsvp, rsvp_opens_at: nil)
        expect(event.rsvp_open?).to be_truthy
      end

      it "is true when rsvp_opens_at is in the past" do
        event = FactoryBot.build(:event, :requires_rsvp, rsvp_opens_at: 1.day.ago)
        expect(event.rsvp_open?).to be_truthy
      end

      it "is false when rsvp_opens_at is in the future" do
        event = FactoryBot.build(:event, :requires_rsvp, rsvp_opens_at: 1.day.from_now)
        expect(event.rsvp_open?).to be_falsey
      end
    end
  end
end
