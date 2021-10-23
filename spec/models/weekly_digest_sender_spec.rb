# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeeklyDigestSender, type: :model do
  before do
    @member = FactoryBot.create(:member)
  end

  describe 'time_to_run' do
    before do
      @sender = WeeklyDigestSender.new
      @unit = FactoryBot.create(:unit)
    end

    it 'returns true' do
      right_now = Time.zone.now.next_week(:sunday).beginning_of_hour.change(hour: 7)
      expect(@sender.time_to_run?(@unit, right_now)).to be_truthy
    end

    it 'returns false' do
      right_now = Time.zone.now.beginning_of_hour.change(min: 5)
      expect(@sender.time_to_run?(@unit, right_now)).to be_falsey
    end
  end
end
