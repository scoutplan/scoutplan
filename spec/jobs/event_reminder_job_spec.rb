require "rails_helper"
require "sidekiq/testing"
require "active_job/test_helper"

RSpec.describe EventReminderJob, type: :job do
  before do
    @unit = FactoryBot.create(:unit)
    @unit.settings(:communication).daily_reminder = "yes"
    @event = FactoryBot.create(:event, :published, unit: @unit)
    @event_with_rsvps = FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit)
    Flipper.enable(:event_reminder_jobs, @unit)

    5.times do
      FactoryBot.create(:unit_membership, unit: @unit)
    end

    3.times do
      member = FactoryBot.create(:unit_membership, unit: @unit)
      @event.rsvps.create!(unit_membership: member, response: "accepted", respondent: member)
    end

    expect(@unit.members.count).to eq(8)
    Sidekiq::Testing.inline!
  end

  it "sends email to attendees" do
    expect { EventReminderJob.perform_now(@event_with_rsvps.id, @event_with_rsvps.updated_at) }
      .to change { ActiveJob::Base.queue_adapter.enqueued_jobs.count }.by(@event_with_rsvps.rsvps.accepted.count)
  end
end
