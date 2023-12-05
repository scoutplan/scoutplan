# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventRsvpNotification do
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
end
