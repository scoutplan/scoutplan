# frozen_string_literal: true

require "rails_helper"

# EventsHelper specs
# rubocop:disable Metrics/BlockLength
RSpec.describe EventsHelper, type: :helper do
  before do
    @member = FactoryBot.create(:member)
    @event = FactoryBot.create(:event, unit: @member.unit)
    @arrival_location = FactoryBot.create(:location, locatable: @event, key: "arrival")
  end

  describe "location_address_string" do
    it "is empty when event lacks both" do
      @arrival_location.name = nil
      @arrival_location.address = nil
      @arrival_location.save!
      expect(location_address_string(@event)).to eq("")
    end

    it "address only" do
      @arrival_location.address = "123 Main Street Anytown, ST 12345"
      @arrival_location.name = nil
      @arrival_location.save!
      expect(location_address_string(@event)).to eq(@arrival_location.address)
    end

    it "location only" do
      @arrival_location.address = nil
      @arrival_location.save!
      expect(location_address_string(@event)).to eq(@arrival_location.name)
    end

    it "address and location" do
      expect(location_address_string(@event)).to eq("#{@arrival_location.name} #{@arrival_location.address}")
    end

    it "prepend" do
      expect(location_address_string(@event, " at ")).to eq(" at #{@arrival_location.name} #{@arrival_location.address}")
    end
  end
end
# rubocop:enable Metrics/BlockLength