require "rails_helper"

RSpec.describe EventShift, type: :model do
  it "has a valid model" do
    expect(FactoryBot.build(:event_shift)).to be_valid
  end
end
