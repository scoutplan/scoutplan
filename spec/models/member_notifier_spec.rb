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
end
