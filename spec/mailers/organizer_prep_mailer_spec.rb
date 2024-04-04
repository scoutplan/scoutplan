require "rails_helper"

RSpec.describe OrganizerPrepMailer, type: :mailer do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @event = FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit)
    @mail = OrganizerPrepMailer.with(recipient: @member, event: @event).organizer_prep_notification
  end

  it "works" do
    expect { @mail.deliver_now }.not_to raise_error
  end

  it "renders the headers" do
    expect(@mail.subject).to eq("[#{@unit.name}] Time to get ready for the #{@event.title} event on #{@event.starts_at.strftime('%B %-d')}")
  end
end
