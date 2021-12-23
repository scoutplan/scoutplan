# frozen_string_literal: true

require 'rails_helper'

def schedule_yaml
  "---\n:start_time: 2021-12-12 12:55:41.000000000 -05:00\n:rrules:\n- :validations:\n    :day:\n    - 1\n    :hour_of_day:\n    - 7\n    :minute_of_hour:\n    - 0\n    :second_of_minute:\n    - 0\n  :rule_type: IceCube::WeeklyRule\n  :interval: 1\n  :week_start: 0\n:rtimes: []\n:extimes: []\n"
end

# rubocop:disable Metrics/BlockLength
RSpec.describe DigestSender, type: :model do
  # this will set up a run at 7:00 AM on Sunday and then simulate two
  # Sundays from now — way past when it should have run
  describe 'time_to_run' do
    before do
      @unit = FactoryBot.create(:unit)
      @unit.settings(:communication).digest_schedule = schedule_yaml
      @sender = DigestSender.new
      @sender.unit = @unit
    end

    it 'returns true when it\'s a week from now' do
      Timecop.freeze(DateTime.now.sunday + 7.days)
      expect(@sender.time_to_run?).to be_truthy
      Timecop.return
    end

    it 'returns false when it\'s a week ago' do
      Timecop.freeze(DateTime.now.sunday - 14.days)
      expect(@sender.time_to_run?).to be_falsey
      Timecop.return
    end
  end

  # this is the method called from Sidekiq scheduler
  describe 'perform' do
    before do
      @member = FactoryBot.create(:member)
      @unit = @member.unit

      # enable digest for the unit
      @unit.settings(:communication).update! digest_schedule: schedule_yaml

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

    it 'sends an email when Flipper is enabled' do
      expect { @sender.perform }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'does not send an email when Flipper is disabled' do
      Flipper.disable_actor :digest, @member
      expect { @sender.perform }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end
  end
end
# rubocop:enable Metrics/BlockLength
