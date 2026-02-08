require "rails_helper"

RSpec.describe RsvpNagJob, type: :job do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
  end

  it "enqueues email" do
    FactoryBot.create(:event, :requires_rsvp, unit: @unit)
    expect { RsvpNagJob.new.perform(@unit.id) }.to have_enqueued_job.at_least(:once)
  end

  it "doesn't enqueue email when member has RSVP'ed to everything" do
    event = FactoryBot.create(:event, :requires_rsvp, unit: @unit)
    event.event_rsvps.create!(member: @member, response: "declined", respondent: @member)

    expect { RsvpNagJob.new.perform(@unit.id) }.not_to have_enqueued_job
  end
end
