require "rails_helper"
require "sidekiq/testing"
require "active_job/test_helper"

RSpec.describe Message, type: :model do
  include ActiveJob::TestHelper

  before do
    @adult = FactoryBot.create(:member)
    @unit = @adult.unit
    @youth = FactoryBot.create(:member, :youth, unit: @unit)
    @adult.child_relationships.create(child_unit_membership: @youth)
  end

  it "has a valid factory" do
    expect(FactoryBot.build(:message)).to be_valid
  end

  # describe "event registered" do
  #   before do
  #     @event = FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit)
  #     @event.rsvps.create!(member: @youth, response: :accepted, respondent: @adult)
  #     @message = @unit.messages.create!(author: @adult, body: "test")
  #     @service = MessageService.new(@message)
  #   end

  #   it "is set up correctly" do
  #     expect(@event.rsvps.count).to eq(1)
  #   end

  #   it "has an event cohort" do
  #     expect(@message.event_cohort?).to be_truthy
  #   end
  # end

  # describe "lifecycle" do
  #   it "enqueues a job" do
  #     expect { FactoryBot.create(:message, unit: @unit) }.to change { enqueued_jobs.count }.by(1)
  #   end
  # end

  describe "dup" do
    before do
    end

    it "creates a new message" do
      message = FactoryBot.create(:message, unit: @unit)
      expect { message.dup }.to change { Message.count }.by(1)
    end

    it "dupes recipients" do
      message = FactoryBot.create(:message, unit: @unit)
      @members = []
      5.times do
        @members << FactoryBot.create(:unit_membership)
        message.message_recipients.create!(unit_membership: @members.last)
      end
      expect(message.message_recipients.count).to eq(5)
      expect { message.dup }.to change { MessageRecipient.count }.by(@members.count)
    end
  end
end
