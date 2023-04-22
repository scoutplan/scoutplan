require "rails_helper"

RSpec.describe RsvpLastCallTask, type: :model do
  describe "" do
    before do
      @member = FactoryBot.create(:member)
      @unit = @member.unit
      @event = FactoryBot.create(:event, :requires_rsvp, :published, unit: @unit,
                                 starts_at: 14.days.from_now, ends_at: 15.days.from_now,
                                 rsvp_closes_at: 1.day.from_now)
      @task = RsvpLastCallTask.new(taskable: @unit, key: "test")
    end
  
    it "sends an email when an event RSVP closes tomorrow" do
      expect { @task.perform }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "doesn't send an email when no event RSVPs close tomorrow" do
      @event.update(rsvp_closes_at: 2.days.from_now)
      expect { @task.perform }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end
  end
end
