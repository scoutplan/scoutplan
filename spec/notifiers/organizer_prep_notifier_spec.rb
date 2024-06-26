require "rails_helper"

RSpec.describe OrganizerPrepNotifier do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TaggedLogging

  let(:name) { "OrganizerPrepNotifier" }

  before do
    @event = FactoryBot.create(:event)
    @unit = @event.unit
    @member = FactoryBot.create(:unit_membership, :adult, unit: @unit)
    @member.user.update(phone: "+13395788645")
  end

  it "creates a notifier" do
    expect(OrganizerPrepNotifier.new).to be_a(ScoutplanNotifier)
  end

  it "delivers an email" do
    expect { OrganizerPrepNotifier.with(event: @event).deliver([@member]) }.to have_enqueued_job(Noticed::EventJob)
  end
end
