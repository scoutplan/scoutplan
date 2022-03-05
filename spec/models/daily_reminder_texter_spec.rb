# frozen_string_literal: true

require "rails_helper"

RSpec.describe DailyReminderTexter, type: :model do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @event = FactoryBot.create(
      :event,
      :published,
      unit: @unit,
      starts_at: DateTime.now.beginning_of_day + 13.hours,
      ends_at: DateTime.now.beginning_of_day + 14.hours
    )
    Timecop.freeze(DateTime.now.beginning_of_day + 1.hour)
  end

  describe "events same day" do
    it "contains the correct start time" do
      texter = DailyReminderTexter.new @member
      expect(texter.body).to include @event.starts_at.in_time_zone(@unit.time_zone).strftime("%-I:%M %p")
    end
  end
end
