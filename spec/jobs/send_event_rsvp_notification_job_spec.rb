# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendEventRsvpNotificationJob, type: :job do
  it "enqueues a job" do
    event_rsvp = FactoryBot.create(:event_rsvp)
    expect { SendEventRsvpNotificationJob.perform_later(event_rsvp) }.to have_enqueued_job
  end
end
