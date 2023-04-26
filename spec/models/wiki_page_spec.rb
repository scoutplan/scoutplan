require 'rails_helper'

RSpec.describe WikiPage, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.create(:wiki_page)).to be_valid
  end
end
