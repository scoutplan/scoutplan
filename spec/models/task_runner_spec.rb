# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskRunner, type: :model do
  it "instantiates" do
    expect { TaskRunner.new }.not_to raise_exception
  end

  it "runs" do
    runner = TaskRunner.new
    expect { runner.perform }.not_to raise_exception
  end
end
