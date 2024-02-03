require "rails_helper"

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

  it "doesn't deliver email if deliver_email is disabled" do
    skip "Test isn't valid...need to learn how to make it so."
    expect { MessageNotifier.with(message: @message).deliver([@member]) }.to change { ActionMailer::Base.deliveries.count }.by(0)
  end
end
