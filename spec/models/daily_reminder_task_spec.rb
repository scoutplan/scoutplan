# frozen_string_literal: true

require "rails_helper"

RSpec.describe DailyReminderTask, type: :model do
  it "instantiates" do
    expect { DailyReminderTask.new }.not_to raise_exception
  end

  it "performs" do
    unit = FactoryBot.create(:unit)
    task = unit.tasks.create(key: "daily_reminder", type: "DailyReminderTask")
    expect { task.perform}.not_to raise_exception
  end
end
