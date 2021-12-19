# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigestSender, type: :model do
  before do
    @member = FactoryBot.create(:member)
  end

  describe 'time_to_run' do
    # this will set up a run at 7:00 AM on Sunday and then simulate two
    # Sundays from now — way past when it should have run
    before do
      schedule_yaml = "---\n:start_time: 2021-12-12 12:55:41.000000000 -05:00\n:rrules:\n- :validations:\n    :day:\n    - 1\n    :hour_of_day:\n    - 7\n    :minute_of_hour:\n    - 0\n    :second_of_minute:\n    - 0\n  :rule_type: IceCube::WeeklyRule\n  :interval: 1\n  :week_start: 0\n:rtimes: []\n:extimes: []\n"
      @unit = FactoryBot.create(:unit)
      @unit.settings(:communication).digest = schedule_yaml
      @sender = DigestSender.new
      @sender.unit = @unit
      @sender.current_datetime = DateTime.now.sunday + 7.days
    end

    it 'returns true' do
      expect(@sender.time_to_run?).to be_truthy
    end

    # it 'returns false' do
    #   right_now = Time.zone.now.beginning_of_hour.change(min: 5)
    #   expect(@sender.time_to_run?(@unit, right_now)).to be_falsey
    # end
  end
end
