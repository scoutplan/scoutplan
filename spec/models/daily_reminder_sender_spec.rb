# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DailyReminderSender, type: :model do
  describe 'time_to_run' do
    before do
      @sender = DailyReminderSender.new
      @member = FactoryBot.create(:member)
    end

    it 'returns true' do
      right_now = Time.zone.now.beginning_of_hour.change(hour: 7)
      expect(@sender.time_to_run?(@member, right_now)).to be_truthy
    end

    it 'returns false' do
      right_now = Time.zone.now.beginning_of_hour.change(hour: 6)
      expect(@sender.time_to_run?(@member, right_now)).to be_falsey
    end
  end
end
