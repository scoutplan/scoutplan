require "rails_helper"

RSpec.describe EventOrganizerMailer, type: :mailer do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @other_member = FactoryBot.create(:member, unit: @unit)
    @event = FactoryBot.create(:event, :requires_rsvp, :published, unit: @unit)
    @organizer = @event.event_organizers.create(unit_membership: @member, assigned_by: @other_member)
  end

  describe "assignment_email" do
    it "works" do
      mail = EventOrganizerMailer.with(recipient: @member, event_organizer: @organizer).assignment_email
      expect { mail.deliver_now }.not_to raise_error
    end
  end
end
