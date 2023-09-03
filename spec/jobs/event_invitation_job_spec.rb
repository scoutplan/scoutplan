# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"
require "active_job/test_helper"

RSpec.describe EventInvitationJob, type: :job do
  include ActiveJob::TestHelper

  before do
    @event = FactoryBot.create(:event, :published, starts_at: 13.days.from_now, ends_at: 14.days.from_now)
    @member = FactoryBot.create(:member, unit: @event.unit)
    @member.settings(:communication).update!(receives_event_invitations: true)
  end

  describe "#perform" do
    it "works" do
      expect { described_class.perform_now(@member) }.not_to raise_error
    end

    it "doesn't enqueue any jobs if the member doesn't receive event invitations" do
      @member.settings(:communication).update!(receives_event_invitations: false)
      expect { described_class.perform_now(@member) }.to change { enqueued_jobs.count }.by(0)
    end

    it "enqueues itself to run tomorrow" do
      @event.update(status: :draft)
      expect { described_class.perform_now(@member) }.to change { enqueued_jobs.count }.by(1)
    end

    it "enqueues an email job" do
      expect { described_class.perform_now(@member) }.to change { enqueued_jobs.count }.by(2)
    end

    it "enqueues multiple email jobs" do
      FactoryBot.create(:event, :published, unit: @event.unit, starts_at: 8.days.from_now, ends_at: 9.days.from_now)
      expect { described_class.perform_now(@member) }.to change { enqueued_jobs.count }.by(3)
    end
  end
end
