require "rails_helper"

shared_examples_for "remindable" do
  let(:model) { described_class }

  it "has a remind! method" do
    expect(model.new).to respond_to(:remind!)
  end

  it "can say when its reminder is due" do
    expect(model.new).to respond_to(:reminder_run_time)
  end
end
