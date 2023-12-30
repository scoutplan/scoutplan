require "rails_helper"
require "sidekiq/testing"
require "active_job/test_helper"

RSpec.describe EventReminderJob, type: :job do
  before do
    @unit = FactoryBot.create(:unit)
    @unit.settings(:communication).event_reminders = "yes"
    @event = FactoryBot.create(:event, :published, unit: @unit)
    @event_with_rsvps = FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit)

    5.times do
      FactoryBot.create(:unit_membership, unit: @unit)
    end

    3.times do
      @member = FactoryBot.create(:unit_membership, unit: @unit)
      @event.rsvps.create!(unit_membership: @member, response: "accepted", respondent: @member)
    end

    expect(@unit.members.count).to eq(8)
    Sidekiq::Testing.inline!
  end

  it "enqueues a job" do
    expect(@member.contactable?(via: :email)).to be_truthy
    expect(@member.contactable?(via: :sms)).to be_truthy

    expect { EventReminderJob.perform_now(@event_with_rsvps.id, @event_with_rsvps.updated_at) }
      .to change { ActiveJob::Base.queue_adapter.enqueued_jobs.count }.by(@event_with_rsvps.rsvps.accepted.count)
  end

  it "doesn't enqueue a job if reminders are disabled for the event category" do
    @event.event_category.update!(send_reminders: false)
    expect { EventReminderJob.perform_now(@event.id, @event.updated_at) }
      .to change { ActiveJob::Base.queue_adapter.enqueued_jobs.count }.by(0)
  end
end
