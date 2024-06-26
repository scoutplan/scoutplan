require "rails_helper"
require "sidekiq/testing"

RSpec.describe EventRsvpOrganizerNotifier do
  include ActiveJob::TestHelper
  # include ActiveSupport::Testing::TaggedLogging

  before do
    @event = FactoryBot.create(:event, :published, :requires_rsvp, allow_youth_rsvps: true)
    @unit = @event.unit
    @youth = FactoryBot.create(:unit_membership, :youth, unit: @unit, allow_youth_rsvps: true)
    @parent = FactoryBot.create(:unit_membership, :youth_with_rsvps, unit: @unit)
    @youth.parent_relationships.create(parent_unit_membership: @parent)
    @unit.update(allow_youth_rsvps: true)
    expect(@youth.parents.count).to eq(1)
  end

  describe "Twilio" do
    it "renders the SMS body" do
      @event.rsvps.create!(unit_membership: @youth, response: "accepted", respondent: @youth)
      notifier = EventRsvpOrganizerNotifier.with(event: @event)
      body = notifier.sms_body(recipient: @youth, event: @event)
      expect(body).to include(@event.title)
      expect(body).to include(@youth.short_display_name)
    end
  end

  describe "youth RSVP" do
    it "creates an RSVP" do
      expect { @event.rsvps.create!(unit_membership: @youth, response: "accepted", respondent: @youth) }
        .to have_enqueued_job.at_least(:once)
    end
  end

  it "delivers" do
    clear_enqueued_jobs
    Sidekiq::Testing.fake!
    organizer_recipients = [@parent]
    expect { EventRsvpOrganizerNotifier.with(record: @event).deliver(organizer_recipients) }.to have_enqueued_job(Noticed::EventJob)
    perform_enqueued_jobs
    expect(ActiveJob::Base.queue_adapter.enqueued_jobs.count).to be > 0
    perform_enqueued_jobs
  end
end
