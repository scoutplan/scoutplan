require "rails_helper"
require "sidekiq/testing"
require "active_job/test_helper"

RSpec.describe Message, type: :model do
  include ActiveJob::TestHelper

  before do
    @adult = FactoryBot.create(:member)
    @unit = @adult.unit
    @youth = FactoryBot.create(:member, :youth, unit: @unit)
    @adult.child_relationships.create(child_member: @youth)
  end

  it "has a valid factory" do
    expect(FactoryBot.build(:message)).to be_valid
  end

  describe "event registered" do
    before do
      @event = FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit)
      @event.rsvps.create!(member: @youth, response: :accepted, respondent: @adult)
      @message = @unit.messages.create!(author: @adult, audience: "event_#{@event.id}_attendees", body: "test")
      @service = MessageService.new(@message)
    end

    it "is set up correctly" do
      expect(@event.rsvps.count).to eq(1)
    end

    it "has an event cohort" do
      expect(@message.event_cohort?).to be_truthy
    end
  end

  describe "lifecycle" do
    it "enqueues a job" do
      expect { FactoryBot.create(:message, unit: @unit) }.to change { enqueued_jobs.count }.by(1)
    end
  end
end
