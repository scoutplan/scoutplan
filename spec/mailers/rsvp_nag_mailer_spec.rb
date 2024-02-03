require "rails_helper"

RSpec.describe RsvpNagMailer, type: :mailer do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @event = FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit)
    @mail = RsvpNagMailer.with(recipient: @member, event: @event).rsvp_nag_notification
  end

  it "works" do
    expect { @mail.deliver_now }.not_to raise_error
  end

  it "renders the headers" do
    expected_subject = "[#{@unit.name}] Are you going to the #{@event.title} on #{@event.starts_at.strftime('%B %-d')}?"
    expect(@mail.subject).to eq(expected_subject)
  end
end
