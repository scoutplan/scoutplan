require "rails_helper"

RSpec.describe Event::Remindable, type: :concern do
  before do
    @event = FactoryBot.create(:event, :published, :requires_rsvp)
  end

  describe "methods" do
    describe "callbacks" do
      it "enqueues an EventReminderJob" do
        expect { FactoryBot.create(:event, :published, :requires_rsvp)}.to have_enqueued_job(EventReminderJob)
      end

      it "enqueues an RsvpLastCallJob" do
        expect { FactoryBot.create(:event, :published, :requires_rsvp) }.to have_enqueued_job(RsvpLastCallJob)
      end
    end
  end
end
