# frozen_string_literal: true

require "rails_helper"

def the_schedule
  result = IceCube::Schedule.new
  result.add_recurrence_rule IceCube::Rule.weekly.day(0).hour_of_day(7)
  result
end

# rubocop:disable Metrics/BlockLength
RSpec.describe DigestSender, type: :model do
  # this will set up a run at 7:00 AM on Sunday and then simulate two
  # Sundays from now — way past when it should have run
  describe "time_to_run" do
    before do
      @unit = FactoryBot.create(:unit)
      @unit.settings(:communication).update! digest_schedule: the_schedule.to_hash
      @sender = DigestSender.new
      @sender.unit = @unit
    end

    it "returns true when it\'s a week from now" do
      Timecop.freeze(DateTime.now.sunday + 7.days)
      expect(@sender.time_to_run?).to be_truthy
      Timecop.return
    end

    it "returns false when it's a week ago" do
      @unit.settings(:communication).update! digest_last_sent_at: 2.days.ago
      Timecop.freeze(DateTime.now.sunday - 14.days)
      expect(@sender.time_to_run?).to be_falsey
      Timecop.return
    end
  end

  # this is the method called from Sidekiq scheduler
  describe "perform" do
    before do
      User.destroy_all
      @member = FactoryBot.create(:member)
      @unit = @member.unit

      # enable digest for the unit
      @unit.settings(:communication).update! digest_schedule: the_schedule.to_hash

      # enable digest for the member
      Flipper.enable_actor :digest, @member

      # pretend it's THE FUTURE
      Timecop.freeze(2.weeks.from_now)

      # stand up the Sender
      @sender = DigestSender.new
    end

    after do
      Timecop.return
    end

    it "sends an email when Flipper is enabled" do
      expect { @sender.perform }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "does not send an email when Flipper is disabled" do
      Flipper.disable_actor :digest, @member
      expect { @sender.perform }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end

    it "raises the high watermark (HWM)" do
      Flipper.enable_actor :digest, @member # make sure member is programmed to receive
      @unit.settings(:communication).update! digest_last_sent_at: nil # clear the HWM
      @unit.reload
      expect(@unit.settings(:communication).digest_last_sent_at).to be_nil
      @sender.perform
      @unit.reload
      expect(@unit.settings(:communication).digest_last_sent_at).not_to be_nil
    end
  end
end
# rubocop:enable Metrics/BlockLength
