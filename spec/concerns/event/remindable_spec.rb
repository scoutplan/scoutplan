# frozen_string_literal: true

require "rails_helper"

RSpec.describe Event::Remindable, type: :concern do
  before do
    @event = FactoryBot.create(:event, :published)
  end

  describe "methods" do
    describe "create_reminder_job!" do
      it "enqueues an EventReminderJob" do
        expect { @event.create_reminder_job! }.to have_enqueued_job(EventReminderJob)
      end
    end
  end
end
