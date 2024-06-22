require "rails_helper"

RSpec.describe EventRsvpOrganizerMailer, type: :mailer do
  before do
    @rsvp = FactoryBot.create(:event_rsvp)
    @event = @rsvp.event
    @unit = @event.unit
    @organizer = FactoryBot.create(:member, :adult, unit: @unit)
    @event.event_organizers.create!(unit_membership: @organizer, assigned_by: @organizer)

    @mail = EventRsvpOrganizerMailer.with(record: @event, recipient: @organizer).event_rsvp_organizer_notification
  end

  describe "event_rsvp_organizer_notification" do
    it "has the correct subject" do
      subject = "[#{@unit.name}] You have new RSVPs for #{@event.title}"
      expect(@mail.subject).to eq(subject)
    end
  end
end
