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
  end

  it "creates a notifier" do
    expect(RsvpLastCallNotifier.new).to be_a(ScoutplanNotifier)
  end

  it "delivers an email" do
    Flipper.enable(:deliver_email)
    # expect { RsvpLastCallNotifier.with(event: @event).deliver([@member]) }.to change { ActionMailer::Base.deliveries.count }.by(1)
    # expect { RsvpLastCallNotifier.with(event: @event).deliver([@member]) }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    expect { RsvpLastCallNotifier.with(event: @event).deliver([@member]) }.to have_enqueued_job(Noticed::EventJob)
  end
end
