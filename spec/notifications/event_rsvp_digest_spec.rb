require "rails_helper"

RSpec.describe MemberNotifier do
  before do
    Time.zone = "America/New_York"
    @event_organizer = FactoryBot.create(:unit_membership)
    @unit = @event_organizer.unit
    @event = FactoryBot.create(:event, :requires_rsvp, unit: @unit)
    @event.organizers.create!(member: @event_organizer, assigned_by: @event_organizer)
    @event.rsvps.create!(member: @event_organizer, respondent: @event_organizer, response: "accepted")
    @task = @unit.tasks.create!(key: "event_organizer_digest", type: "EventOrganizerDigestTask")
  end

  it "sends an email to the event organizer" do
    expect { @task.perform }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
  end

  it "also sends an email to an 'All RSVPs' recipient" do
    @unit_admin = FactoryBot.create(:unit_membership, unit: @unit, role: :admin)
    @unit_admin.settings(:communication).receives_all_rsvps = "true"
    @unit_admin.save!

    5.times do
      FactoryBot.create(:unit_membership, unit: @unit)
    end

    expect { @task.perform }.to have_enqueued_job(ActionMailer::MailDeliveryJob).twice
  end
end
