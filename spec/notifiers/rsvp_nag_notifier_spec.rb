require "rails_helper"

RSpec.describe RsvpNagNotifier do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TaggedLogging

  let(:name) { "RsvpNagNotifier" }

  before do
    @event = FactoryBot.create(:event, :published, :requires_rsvp)
    @member = FactoryBot.create(:unit_membership, :adult, unit: @event.unit)
    @member.user.update(phone: "+13395788645")
    @unit = @event.unit
    Flipper.enable(:rsvp_nag, @member)
  end

  it "creates a notifier" do
    expect(RsvpNagNotifier.new).to be_a(RsvpNagNotifier)
  end

  it "enqueues a Noticed::EventJob" do
    expect { RsvpNagNotifier.with(event: @event).deliver([@member]) }.to have_enqueued_job(Noticed::EventJob)
  end

  it "delivers an email when enabled" do
    skip
    @unit.settings(:communication).update(rsvp_nag: "true")
    perform_enqueued_jobs do
      expect { RsvpNagNotifier.with(event: @event).deliver(@member) }.to have_enqueued_job
    end
  end
end
