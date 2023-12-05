# frozen_string_literal: true

require "rails_helper"

RSpec.describe Event::Onlineable, type: :concern do
  before do
    @event = FactoryBot.create(:event)
  end

  describe "methods" do
    describe "create_reminder_job!" do
      it "enqueues an EventReminderJob" do
        skip
      end
    end

    describe "remind!" do
      it "sends an EventReminder" do
        skip
      end
    end
  end
end
