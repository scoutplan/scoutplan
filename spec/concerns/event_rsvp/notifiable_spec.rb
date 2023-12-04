require "rails_helper"

RSpec.describe EventRsvp::Notifiable, type: :concern do
  before do
    @event = FactoryBot.create(:event, :published, :requires_rsvp)
    @unit = @event.unit
    @member = FactoryBot.create(:member, :adult, unit: @unit)
  end

  describe "callbacks" do
    it "enqueues a job to send an email" do
      rsvp = FactoryBot.build(:event_rsvp, event: @event, member: @member, respondent: @member)
      expect { rsvp.save! }.to have_enqueued_job(Noticed::DeliveryMethods::Email)
    end

    it "enqueues a job to send an SMS" do
      rsvp = FactoryBot.build(:event_rsvp, event: @event, member: @member, respondent: @member)
      expect { rsvp.save! }.to have_enqueued_job(Noticed::DeliveryMethods::Twilio)
    end
  end
end
