require "rails_helper"

RSpec.describe EventRsvpOrganizerNotificationJob, type: :job do
  before do
    @event = FactoryBot.create(:event)
  end

  it "works" do
    expect { EventRsvpOrganizerNotificationJob.perform_now(@event) }.to have_enqueued_job
  end
end
