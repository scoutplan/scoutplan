require "rails_helper"

RSpec.describe Event::Remindable, type: :concern do
  before do
    # @event = FactoryBot.create(:event, :published, :requires_rsvp)
    # @unit = @event.unit
    @unit = FactoryBot.create(:unit)
    Time.zone = @unit.time_zone
  end

  describe "methods" do
    describe "callbacks" do
      it "enqueues an EventReminderJob" do
        expect { FactoryBot.create(:event, :published, :requires_rsvp) }.to have_enqueued_job(EventReminderJob)
      end

      it "enqueues an RsvpLastCallJob" do
        starts_at = 4.days.from_now
        ends_at = 5.days.from_now
        rsvp_closes_at = 3.days.from_now.at_end_of_day
        last_call_lead_time = rsvp_closes_at - Event::Remindable::LAST_CALL_LEAD_TIME
        rsvp_last_call_at = @unit.in_business_hours(last_call_lead_time)

        expect { FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit, starts_at: starts_at, ends_at: ends_at, rsvp_closes_at: rsvp_closes_at) }
          .to have_enqueued_job(RsvpLastCallJob).on_queue("default").at(rsvp_last_call_at)
      end
    end
  end
end
