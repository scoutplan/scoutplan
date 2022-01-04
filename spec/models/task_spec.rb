# frozen_string_literal: true

require "rails_helper"

class TestTask < Task; end

def schedule
  IceCube::Schedule
    .new
    .add_recurrence_rule IceCube::Rule.weekly.day(0).hour_of_day(7)
end

# rubocop:disable Metrics/BlockLength
RSpec.describe Task, type: :model do
  it "instantiates" do
    expect { Task.new }.not_to raise_exception
  end

  describe "validations" do
    before do
      @unit = FactoryBot.create(:unit)
    end

    it "requires a key" do
      expect(@unit.tasks.new(type: "TestTask", key: nil)).not_to be_valid
    end

    it "prevents duplicate keys" do
      key_name = "shazam!"
      task = @unit.tasks.create(type: "TestTask", key: key_name)
      expect(task).to be_valid
      expect(@unit.tasks.new(type: "TestTask", key: key_name)).not_to be_valid
    end
  end

  describe "time_to_run" do
    before do
      @task = Task.new
      @task.schedule.add_recurrence_rule IceCube::Rule.weekly.day(0).hour_of_day(7)
    end

    it "returns true when it's a week from now" do
      Timecop.freeze(DateTime.now.sunday + 7.days)
      expect(@task.time_to_run?).to be_truthy
      Timecop.return
    end

    it "returns false when it's a week ago" do
      Timecop.freeze(DateTime.now.sunday - 14.days)
      expect(@task.time_to_run?).to be_falsey
      Timecop.return
    end
  end

  describe "set high watermark" do
    before do
      @unit = FactoryBot.create(:unit)
      @task = @unit.tasks.create(key: "digest", type: "TestTask")
    end

    it "persists last runtime" do
      @task.set_high_watermark
      @task.reload
      expect(@task.last_ran_at).to be_within(1.second).of DateTime.now
    end

    it "sets high watermark after perform" do
      @task.perform
      @task.reload
      expect(@task.last_ran_at).to be_within(1.second).of DateTime.now
    end
  end
end
# rubocop:enable Metrics/BlockLength
