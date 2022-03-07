# frozen_string_literal: true

require "rails_helper"

RSpec.describe NewsItem, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.build(:news_item)).to be_valid
  end
end
