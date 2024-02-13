require "rails_helper"

RSpec.describe Message::Sendable, type: :concern do
  before do
    @member = FactoryBot.create(:member, :admin)
    @unit = @member.unit
  end

  describe "callbacks" do
    it "enqueues an email job" do
      params = {
        title:  "I can't believe it's not butter!",
        body:   "Nope. Parkay!",
        sender: @member,
        status: :outbox
      }
      @message = @unit.messages.new(params)
      expect { @message.save! }.to have_enqueued_job(SendMessageJob)
    end
  end

  describe "methods" do
    it "sends a message" do
      @message = FactoryBot.create(:message, :outbox, unit: @unit)
      expect { @message.send! }.to have_enqueued_job(Noticed::EventJob)
    end
  end
end
