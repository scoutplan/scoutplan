require "rails_helper"

RSpec.describe RsvpLastCallJob, type: :job do
  before do
    @event = FactoryBot.create(:event, :published, :requires_rsvp)
    @unit = @event.unit
    @non_respondent = FactoryBot.create(:unit_membership, unit: @unit)
  end

  it "invokes the RsvpLastCallNotifier" do
    expect { RsvpLastCallJob.new.perform(@event.id, @event.updated_at) }.to have_enqueued_job.at_least(:once)
  end
end
