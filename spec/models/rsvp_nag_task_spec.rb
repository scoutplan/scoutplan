# frozen_string_literal: true

require "rails_helper"

RSpec.describe RsvpNagTask, type: :model do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
  end

  it "updates high water mark" do
    task = RsvpNagTask.new(taskable: @unit, key: "test")
    task.perform
    expect(task.last_ran_at).to be_within(1.second).of(DateTime.now)
  end
end
