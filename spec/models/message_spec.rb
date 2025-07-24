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

  describe "dup" do
    # it "creates a new message" do
    #   message = FactoryBot.create(:message, unit: @unit)
    #   expect { message.dup }.to change { Message.count }.by(1)
    # end

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
