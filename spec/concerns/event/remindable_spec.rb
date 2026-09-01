require "rails_helper"

RSpec.describe Event::Remindable, type: :concern do
  before do
    @unit = FactoryBot.create(:unit)
    Time.zone = @unit.time_zone
  end

  # Reminders used to be enqueued from an after_commit the moment an event was saved, which left a
  # scheduled job per event in the queue for up to a year. ScheduledJobDispatcherJob now scans a
  # short window instead, and these methods are the contract it reads: "when should this fire, if
  # at all". The specs below cover that contract rather than the callback that used to exist.
  describe "#reminder_run_time" do
    it "is REMINDER_LEAD_TIME before the start, shifted into business hours" do
      event = FactoryBot.create(:event, :published, unit: @unit,
                                starts_at: 4.days.from_now, ends_at: 4.days.from_now + 2.hours)
      expected = @unit.in_business_hours(event.starts_at - Event::Remindable::REMINDER_LEAD_TIME)

      expect(event.reminder_run_time).to be_within(1.second).of(expected)
    end

    it "is nil for a draft" do
      event = FactoryBot.create(:event, unit: @unit,
                                starts_at: 4.days.from_now, ends_at: 5.days.from_now)

      expect(event.reminder_run_time).to be_nil
    end

    it "is nil once the event has started" do
      event = FactoryBot.create(:event, :published, unit: @unit,
                                starts_at: 3.days.ago, ends_at: 2.days.ago)

      expect(event.reminder_run_time).to be_nil
    end
  end

  describe "#last_call_run_time" do
    it "is LAST_CALL_LEAD_TIME before the RSVP closes, shifted into business hours" do
      rsvp_closes_at = 3.days.from_now.at_end_of_day
      event = FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit,
                                starts_at: 4.days.from_now, ends_at: 5.days.from_now,
                                rsvp_closes_at: rsvp_closes_at)
      expected = @unit.in_business_hours(event.rsvp_closes_at - Event::Remindable::LAST_CALL_LEAD_TIME)

      expect(event.last_call_run_time).to be_within(1.second).of(expected)
    end

    it "is nil when the event does not require an RSVP" do
      event = FactoryBot.create(:event, :published, unit: @unit,
                                starts_at: 4.days.from_now, ends_at: 5.days.from_now)

      expect(event.last_call_run_time).to be_nil
    end
  end

  describe "callbacks" do
    it "does not enqueue reminder work on save" do
      expect { FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit) }
        .not_to have_enqueued_job(EventReminderJob)
    end
  end
end
