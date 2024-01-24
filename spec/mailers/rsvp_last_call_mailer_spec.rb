require "rails_helper"

RSpec.describe RsvpNagMailer, type: :mailer do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @event = FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit)
    @mail = RsvpLastCallMailer.with(recipient: @member, event: @event).rsvp_last_call_notification
  end

  it "works" do
    expect { @mail.deliver_now }.not_to raise_error
  end

  it "renders the headers" do
    expect(@mail.subject).to eq("[#{@unit.name}] Are you going to the #{@event.title} on #{@event.starts_at.strftime('%B %-d')}?")
  end
end
