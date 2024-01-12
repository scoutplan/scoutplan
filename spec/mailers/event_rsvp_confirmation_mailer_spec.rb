require "rails_helper"

RSpec.describe EventRsvpConfirmationMailer, type: :mailer do
  before do
    @rsvp = FactoryBot.create(:event_rsvp)
    @event = @rsvp.event
    @unit = @event.unit
    @organizer = FactoryBot.create(:member, :adult, unit: @unit)
    @event.event_organizers.create!(unit_membership: @organizer, assigned_by: @organizer)
  end

  describe "event_rsvp_confirmation" do
    it "works" do
      expect { EventRsvpConfirmationMailer.with(event_rsvp: @rsvp, recipient: @organizer).event_rsvp_confirmation.deliver_now }.not_to raise_error
    end
  end
end
