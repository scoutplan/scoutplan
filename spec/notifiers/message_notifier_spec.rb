require "rails_helper"

Response = Struct.new(:code, :uri, :body)

RSpec.describe MessageNotifier do
  before do
    @event = FactoryBot.create(:event)
    @member = FactoryBot.create(:unit_membership, unit: @event.unit)
    @member.user.update(phone: "+13395788645")
    @unit = @event.unit
    @unit.settings(:communication).event_reminders = "true"
    @message = FactoryBot.create(:message, unit: @unit, author: @member, body: "<div>asd</div>")
  end

  it "creates a notifier" do
    expect(MessageNotifier.new).to be_a(ScoutplanNotifier)
  end

  it "delivers an email" do
    Flipper.enable(:deliver_email)
    expect { MessageNotifier.with(message: @message).deliver([@member]) }.to have_enqueued_job
  end

  it "handles Noticed::ResponseUnsuccessful" do
    notifier = MessageNotifier.with(message: @message)
    response = Response.new(400, "https://api.twilio.com/2010-04-01/Accounts/12345/Messages.json", [])
    allow(notifier).to receive(:deliver).and_raise(Noticed::ResponseUnsuccessful.new(response, "https://api.twilio.com/2010-04-01/Accounts/12345/Messages.json", []))
    expect { notifier.deliver([@member]) }.to raise_error
  end
end
