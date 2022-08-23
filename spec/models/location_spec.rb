require "rails_helper"

RSpec.describe Location, type: :model do
  it "has a valid factory" do
    event = FactoryBot.create(:event)
    expect(FactoryBot.build(:location, locatable: event)).to be_valid
  end

  it "prevents duplicates" do
    event = FactoryBot.create(:event)
    key = "test_key"
    FactoryBot.create(:location, locatable: event, key: key)
    expect(FactoryBot.build(:location, locatable: event, key: key)).not_to be_valid
  end
end
