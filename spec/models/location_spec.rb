# frozen_string_literal: true

require "rails_helper"

RSpec.describe Location, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.build(:location)).to be_valid
  end

  describe "methods" do
    before do
      @location = FactoryBot.create(:location)
    end

    describe "full_address" do
      it "displays when only name is set" do
        @location.map_name = nil
        @location.address = ""
        @location.phone = nil
        @location.website = nil
        @location.save!
        expect(@location.full_address).to eq(@location.name)
      end

      it "displays when name and address are set" do
        @location.update(map_name: nil)
        expect(@location.full_address).to eq("#{@location.name}, #{@location.address}")
      end
    end
  end
end
