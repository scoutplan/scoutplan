# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"
require "active_job/test_helper"

RSpec.describe Event::Invitations, type: :concern do
  include ActiveJob::TestHelper

  before do
    @event = FactoryBot.create(:event, starts_at: 21.days.from_now, ends_at: 22.days.from_now)
    @member = FactoryBot.create(:member, unit: @event.unit)
  end

  describe "invite!" do
    it "sends an EventInvitation email" do
      expect { @event.invite!(@member) }.to change { enqueued_jobs.count }.by(1)
    end
  end

  describe "invite_at" do
    it "returns the event start time minus the invitation lead time" do
      expect(@event.invite_at(@member)).to eq(@event.starts_at - Event::Invitations::DEFAULT_INVITATION_LEAD_TIME)
    end
  end

  describe "invited?" do
    it "returns true if the member's already been invited" do
      EventInvitation.create(event: @event, unit_membership: @member)
      expect(@event.invited?(@member)).to be_truthy
    end

    it "returns false if the member hasn't already been invited" do
      expect(@event.invited?(@member)).to be_falsey
    end
  end

  describe "should_invite?" do
    it "returns true if the event reminder window started in the past and the member hasn't been invited" do
      @event.starts_at = 13.days.from_now
      expect(@event.should_invite?(@member)).to be_truthy
    end

    it "returns false if the event reminder window hasn't started yet" do
      expect(@event.should_invite?(@member)).to be_falsey
    end

    it "returns false if the member's already been invited" do
      @event.starts_at = 13.days.from_now
      EventInvitation.create(event: @event, unit_membership: @member)
      expect(@event.should_invite?(@member)).to be_falsey
    end
  end

  describe "invitation_lead_time" do
    it "returns 14 days" do
      expect(@event.invitation_lead_time(@member)).to eq(Event::Invitations::DEFAULT_INVITATION_LEAD_TIME)
    end
  end
end
