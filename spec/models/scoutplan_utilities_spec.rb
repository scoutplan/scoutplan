# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScoutplanUtilities, type: :model do
  describe 'compose_datetime' do
    it 'parses %Y-%m-%d %H:%M:%S' do
      date_str = '2021-09-01'
      time_str = '16:00:00'
      result = ScoutplanUtilities.compose_datetime(date_str, time_str)
      expect(result.year).to eq(2021)
      expect(result.month).to eq(9)
    end

    it 'parses AM/PM time' do
      date_str = '2021-09-01'
      time_str = '4:00:00 PM'
      result = ScoutplanUtilities.compose_datetime(date_str, time_str)
      expect(result.year).to eq(2021)
      expect(result.hour).to eq(16)
    end

    it 'parses AM/PM time without seconds' do
      date_str = 'Sept 1, 2021'
      time_str = '4:00 PM'
      result = ScoutplanUtilities.compose_datetime(date_str, time_str)
      expect(result.year).to eq(2021)
      expect(result.hour).to eq(16)
    end
  end
end
