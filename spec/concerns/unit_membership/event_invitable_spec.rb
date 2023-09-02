# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"
require "active_job/test_helper"

RSpec.describe UnitMembership::EventInvitable, type: :concern do
  include ActiveJob::TestHelper

  before do
    @event = FactoryBot.create(:event)
    @member = FactoryBot.create(:member, unit: @event.unit)
  end

  describe "methods" do
    describe "receives_event_invitations?" do
      it "returns true if the member receives event invitations" do
        @member.settings(:communication).receives_event_invitations = true
        expect(@member.receives_event_invitations?).to be_truthy
      end

      it "returns false if the member does not receive event invitations" do
        expect(@member.receives_event_invitations?).to be_falsey
      end
    end

    describe "next_event_invitation_runs_at" do
      it "returns tomorrow at 10am" do
        next_run_time = Date.tomorrow.in_time_zone.change(
          hour: UnitMembership::EventInvitable::RUNS_AT_HOUR,
          min:  0,
          sec:  0
        )
        expect(@member.next_event_invitation_runs_at).to eq(next_run_time)
      end
    end
  end

  describe "callbacks" do
    describe "after_commit" do
      it "enqueues an EventInvitationJob when event invitations are enabled" do
        @member.settings(:communication).update!(receives_event_invitations: true)
        expect { @member.touch }.to change { enqueued_jobs.count }.by(1)
      end

      it "does not enqueue an EventInvitationJob when event invitations are disabled" do
        expect { @event.touch }.to change { enqueued_jobs.count }.by(0)
      end
    end
  end
end
