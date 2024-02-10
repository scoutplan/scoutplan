require "rails_helper"
require "sidekiq/testing"

RSpec.describe WeeklyDigestNotifier do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TaggedLogging

  let(:name) { "RsvpLastCallNotifier" }

  before do
    @event = FactoryBot.create(:event)
    @unit = @event.unit
    @member = FactoryBot.create(:unit_membership, :adult, unit: @unit)
    @unit.unit_memberships.each do |member|
      member.user.update(phone: "+15005550006")
    end
  end

  it "creates a notifier" do
    expect(WeeklyDigestNotifier.new).to be_a(ScoutplanNotifier)
  end

  it "delivers an email" do

    # skip "This test works standalone, but not in the suite. It's a known issue."
    Flipper.enable(:deliver_email)

    clear_enqueued_jobs

    # Sidekiq::Testing.inline!
    Sidekiq::Testing.fake!
    expect { WeeklyDigestNotifier.with(unit: @unit).deliver(@unit.unit_memberships.first) }.to have_enqueued_job(Noticed::EventJob)

    perform_enqueued_jobs
    expect(ActiveJob::Base.queue_adapter.enqueued_jobs.count).to be > 0
    perform_enqueued_jobs
    expect(ActionMailer::Base.deliveries.count).to eq(1)
  end
end
