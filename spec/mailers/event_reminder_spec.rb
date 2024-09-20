require "rails_helper"

RSpec.describe EventReminderMailer, type: :mailer do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @other_member = FactoryBot.create(:member, unit: @unit)
    @event = FactoryBot.create(:event, :requires_rsvp, :published, unit: @unit, starts_at: 3.hours.from_now)
    @organizer = @event.event_organizers.create(unit_membership: @member, assigned_by: @other_member)
  end

  describe "event_reminder_notification" do
    it "works" do
      mail = EventReminderMailer.with(recipient: @member, event: @event).event_reminder_notification
      expect(mail.body.encoded).to include(@event.title)
      expect(mail.body.encoded).to include("today")
      expect { mail.deliver_now }.not_to raise_error
    end
  end
end
