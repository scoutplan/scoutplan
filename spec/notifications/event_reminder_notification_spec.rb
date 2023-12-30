# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventReminderNotification do
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
    expect(EventReminderNotification.new).to be_a(ScoutplanNotification)
  end

  it "delivers an email" do
    Flipper.enable(:deliver_email)
    expect { EventReminderNotification.with(event: @event).deliver([@member]) }
      .to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it "renders the SMS correctly" do
    Time.zone = "UTC" # server time
    notification = EventReminderNotification.with(event: @event)
    sms = notification.sms_body(recipient: @member, event: @event, params: {})
    expect(sms).to(include @event.starts_at.in_time_zone(@unit.time_zone).strftime("%A"))
  end
end
