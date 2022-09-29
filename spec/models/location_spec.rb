require "rails_helper"

RSpec.describe Location, type: :model do
  it "has a valid factory" do
    event = FactoryBot.create(:event)
    expect(FactoryBot.build(:location, locatable: event)).to be_valid
  end
end
