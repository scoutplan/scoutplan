# frozen_string_literal: true

require "rails_helper"

RSpec.describe DailyReminderTask, type: :model do
  before do
    @unit = FactoryBot.create(:unit)
    @task = @unit.tasks.create(key: "daily_reminder", type: "DailyReminderTask")
  end

  it "instantiates" do
    expect { DailyReminderTask.new }.not_to raise_exception
  end

  it "performs" do
    expect { @task.perform }.not_to raise_exception
  end

  it "returns the correct description" do
    expect(@task.description).to eq(I18n.t("tasks.daily_reminder_description"))
  end
end
