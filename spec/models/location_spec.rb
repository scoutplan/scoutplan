# frozen_string_literal: true

require "rails_helper"

RSpec.describe Location, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.build(:location)).to be_valid
  end
end
