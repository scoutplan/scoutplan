require "rails_helper"

RSpec.describe RsvpNagJob, type: :job do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @unit.settings(:communication).update!(config_timestamp: DateTime.current)
  end

  # it "performs" do
  #   expect { RsvpNagJob.new.perform(@unit.id, @unit.settings(:communication).config_timestamp) }.not_to raise_error
  # end

  it "enqueues email" do
    FactoryBot.create(:event, :requires_rsvp, unit: @unit)
    expect { RsvpNagJob.new.perform(@unit.id, @unit.settings(:communication).config_timestamp) }.to have_enqueued_job.at_least(:twice)
  end

  it "doesn't enqueue email when member has RSVP'ed to everything" do
    event = FactoryBot.create(:event, :requires_rsvp, unit: @unit)
    event.event_rsvps.create!(member: @member, response: "declined", respondent: @member)

    # we should expect only one job: the next RsvpNagJob
    expect { RsvpNagJob.new.perform(@unit.id, @unit.settings(:communication).config_timestamp) }.to have_enqueued_job.exactly(:once)
  end

  # it "schedules the next job" do
  #   expect { RsvpNagJob.schedule_next_job(@unit) }.to have_enqueued_job(RsvpNagJob)
  # end
end
