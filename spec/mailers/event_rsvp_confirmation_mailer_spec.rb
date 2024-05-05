require "rails_helper"

RSpec.describe EventRsvpConfirmationMailer, type: :mailer do
  before do
    @rsvp = FactoryBot.create(:event_rsvp, response: "accepted")
    @event = @rsvp.event
    @unit = @event.unit
    @recipient = @rsvp.unit_membership
    @organizer = FactoryBot.create(:member, :adult, unit: @unit)
    @event.event_organizers.create!(unit_membership: @organizer, assigned_by: @organizer)
  end

  describe "event_rsvp_confirmation" do
    it "works" do
      expect { EventRsvpConfirmationMailer.with(event_rsvp: @rsvp, recipient: @recipient).event_rsvp_confirmation.deliver_now }.not_to raise_error
    end

    it "works when organizer lacks a phone number" do
      @organizer.user.update!(phone: nil)
      expect { EventRsvpConfirmationMailer.with(event_rsvp: @rsvp, recipient: @recipient).event_rsvp_confirmation.deliver_now }.not_to raise_error
    end
  end
end
