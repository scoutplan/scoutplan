require "rails_helper"

RSpec.describe RsvpLastCallJob, type: :job do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TaggedLogging

  let(:name) { "RsvpLastCallJob" }

  before do
    @event = FactoryBot.create(:event, :published, :requires_rsvp)
    @unit = @event.unit
    @non_respondent = FactoryBot.create(:unit_membership, unit: @unit)
  end

  it "invokes the RsvpLastCallNotifier" do
    clear_enqueued_jobs
    expect { RsvpLastCallJob.new.perform(@event.id, @event.updated_at) }.to have_enqueued_job.at_least(:once)
    perform_enqueued_jobs
    expect(@event.notifications.where(type: "RsvpLastCallNotifier::Notification").count).to eq(4)

    # if run a second time, it shouldn't do anything
    expect { RsvpLastCallJob.new.perform(@event.id, @event.updated_at) }.not_to have_enqueued_job.at_least(:once)
    perform_enqueued_jobs
    expect(@event.notifications.where(type: "RsvpLastCallNotifier::Notification").count).to eq(4)
  end
end
