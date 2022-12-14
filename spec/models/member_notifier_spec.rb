# frozen_string_literal: true

require "rails_helper"

RSpec.describe MemberNotifier, type: :model do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
  end

  it "instantiates" do
    expect { MemberNotifier.new(@member) }.not_to raise_exception
  end

  describe "methods" do
    before do
      @notifier = MemberNotifier.new(@member)
    end

    it "sends a test message" do
      expect { @notifier.send_test_message }.not_to raise_exception
    end

    it "skips reminders when member has declined" do
      Timecop.freeze(DateTime.now.change( { hour: 9, minute: 0 } ))
      event = FactoryBot.create(:event, unit: @unit, starts_at: 12.hours.from_now,
                                        requires_rsvp: true, status: :published)
      event.rsvps.create!(unit_membership: @member, response: :declined, respondent: @member)
      expect { @notifier.send_daily_reminder }.to change { ActionMailer::Base.deliveries.count }.by(0)
      Timecop.return
    end
  end

  describe "event organizer digest" do
    before do
      @event = FactoryBot.create(:event, unit: @unit, status: "published", starts_at: 12.hours.from_now)
      @event.event_organizers.create!(unit_membership: @member)
      accepting_member = FactoryBot.create(:member, unit: @unit)
      declining_member = FactoryBot.create(:member, unit: @unit)
      @event.rsvps.create!(unit_membership: accepting_member, response: :accepted, respondent: @member)
      @event.rsvps.create!(unit_membership: declining_member, response: :declined, respondent: @member)
    end

    it "is set up correctly" do
      @event.reload
      expect(@event.organizers.count).to eq(1)
      expect(@event.organizers.map(&:unit_membership)).to include(@member)
      expect(@member.organized_events).to include(@event)
      expect(@event.rsvps.count).to eq(2)
    end

    it "sends a digest" do
      notifier = MemberNotifier.new(@member)
      expect { notifier.send_event_organizer_digest }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
