# frozen_string_literal: true

require "rails_helper"

RSpec.describe RsvpRemindersFiveDays, type: :model do
  it "performs" do
    FactoryBot.create(:unit)
    reminder = RsvpRemindersFiveDays.new
    expect { reminder.perform }.not_to raise_exception
  end
end
