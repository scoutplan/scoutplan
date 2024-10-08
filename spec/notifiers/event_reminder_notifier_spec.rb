require "rails_helper"

RSpec.describe EventReminderNotifier do
  include ActiveJob::TestHelper

  before do
    Time.zone = "America/New_York"
    @event = FactoryBot.create(:event, starts_at: Time.current.change(hour: 19, min: 30))
    @member = FactoryBot.create(:unit_membership, unit: @event.unit)
    @member.user.update(phone: "+13395788645")
    @unit = @event.unit
    @unit.settings(:locale).time_zone = "America/New_York"
    @unit.settings(:communication).event_reminders = "true"
  end

  it "creates a notifier" do
    expect(EventReminderNotifier.new).to be_a(ScoutplanNotifier)
  end

  it "delivers an email" do
    clear_enqueued_jobs
    Flipper.enable(:deliver_email)
    expect { EventReminderNotifier.with(event: @event).deliver([@member]) }.to have_enqueued_job
    perform_enqueued_jobs
    perform_enqueued_jobs
  end

  it "renders the SMS correctly" do
    clear_enqueued_jobs
    Time.zone = "UTC" # server time
    notification = EventReminderNotifier.with(event: @event)
    sms = notification.sms_body(recipient: @member, event: @event, params: {})
    expect(sms).to(include "today")
    puts sms

    @event.starts_at = 1.day.from_now
    notification = EventReminderNotifier.with(event: @event)
    sms = notification.sms_body(recipient: @member, event: @event, params: {})
    expect(sms).to(include "tomorrow")
    puts sms

    perform_enqueued_jobs
    perform_enqueued_jobs
  end
end
