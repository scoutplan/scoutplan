require "rails_helper"

RSpec.describe RsvpLastCallNotifier do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TaggedLogging

  let(:name) { "RsvpLastCallNotifier" }

  before do
    @event = FactoryBot.create(:event)
    @unit = @event.unit
    @member = FactoryBot.create(:unit_membership, :adult, unit: @unit)
    @member.user.update(phone: "+13395788645")
    @member.settings(:communication).update!(via_email: true)
  end

  it "creates a notifier" do
    expect(RsvpLastCallNotifier.new).to be_a(ScoutplanNotifier)
  end

  it "delivers an email" do
    expect(@event.notifications.where(type: "RsvpLastCallNotifier::Notification").count).to eq(0)
    Flipper.enable(:deliver_email)
    clear_enqueued_jobs
    expect { RsvpLastCallNotifier.with(record: @event, event: @event).deliver([@member]) }.to have_enqueued_job(Noticed::EventJob)
    perform_enqueued_jobs
    expect(ActiveJob::Base.queue_adapter.enqueued_jobs.count).to be > 0
    perform_enqueued_jobs
    expect(ActionMailer::Base.deliveries.count).to eq(1)
  end

  it "renders SMS text" do
    notifier = RsvpLastCallNotifier.new
    expect{notifier.sms_body(recipient: @member, event: @event, unit: @unit)}.not_to raise_exception
  end
end
