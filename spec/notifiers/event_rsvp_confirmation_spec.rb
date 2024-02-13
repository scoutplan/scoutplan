require "rails_helper"

RSpec.describe EventRsvpConfirmation do
  include ActiveJob::TestHelper

  before do
    @event = FactoryBot.create(:event, :published, :requires_rsvp, allow_youth_rsvps: true)
    @unit = @event.unit
    @youth = FactoryBot.create(:unit_membership, :youth, unit: @unit, allow_youth_rsvps: true)
    @parent = FactoryBot.create(:unit_membership, :youth_with_rsvps, unit: @unit)
    @youth.parent_relationships.create(parent_unit_membership: @parent)
    @unit.update(allow_youth_rsvps: true)
    expect(@youth.parents.count).to eq(1)
  end

  describe "youth RSVP" do
    it "creates an RSVP" do
      expect { @event.rsvps.create!(unit_membership: @youth, response: "accepted", respondent: @youth) }
        .to change(EventRsvp, :count).by(1)
    end

    it "notifies youth and parent" do
      expect { @event.rsvps.create(unit_membership: @youth, response: "declined", respondent: @youth) }
        .to have_enqueued_job.at_least(:once)
    end
  end

  describe "methods" do
    before do
      @rsvp = @event.rsvps.create!(unit_membership: @youth, response: "accepted", respondent: @parent)
    end

    it "renders the SMS body correctly" do
      confirmation = EventRsvpConfirmation.with(event_rsvp: @rsvp)
      body = confirmation.sms_body(recipient: @youth, event_rsvp: @rsvp)
      expect(body).to include(@event.title)
    end

    it "delivers an email" do
      Flipper.enable(:deliver_email)
      clear_enqueued_jobs
      expect { EventRsvpConfirmation.with(event_rsvp: @rsvp).deliver(@unit.unit_memberships.first) }.to have_enqueued_job(Noticed::EventJob)
      perform_enqueued_jobs
      expect(ActiveJob::Base.queue_adapter.enqueued_jobs.count).to be > 0
      perform_enqueued_jobs
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end
  end
end
