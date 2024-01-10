require "rails_helper"

RSpec.describe EventRsvp::Notifiable, type: :concern do
  before do
    @event = FactoryBot.create(:event, :published, :requires_rsvp)
    @unit = @event.unit
    @member = FactoryBot.create(:member, :adult, unit: @unit)
    @organizer = FactoryBot.create(:member, :adult, unit: @unit)
    @event.event_organizers.create!(unit_membership: @organizer, assigned_by: @organizer)
  end

  describe "callbacks" do
    it "enqueues a two email jobs" do
      rsvp = FactoryBot.build(:event_rsvp, event: @event, member: @member, respondent: @member)

      expect { rsvp.save! }.to have_enqueued_job(Noticed::DeliveryMethods::Email).twice
    end

    it "enqueues two SMS jobs" do
      rsvp = FactoryBot.build(:event_rsvp, event: @event, member: @member, respondent: @member)
      expect { rsvp.save! }.to have_enqueued_job(Noticed::DeliveryMethods::Twilio).twice
    end
  end
end
