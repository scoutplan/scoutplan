# frozen_string_literal: true

require "rails_helper"

# EventsHelper specs
# rubocop:disable Metrics/BlockLength
RSpec.describe EventsHelper, type: :helper do
  before do
    @member = FactoryBot.create(:member)
    @event = FactoryBot.create(:event, unit: @member.unit)
  end

  describe "location_address_string" do
    it "is empty when event lacks both" do
      @event.location = nil
      @event.address = nil
      expect(location_address_string(@event)).to eq("")
    end

    it "address only" do
      @event.address = "Community Center"
      @event.location = nil
      expect(location_address_string(@event)).to eq("Community Center")
    end

    it "location only" do
      @event.address = nil
      @event.location = "123 Main Street Anytown, ST 12345"
      expect(location_address_string(@event)).to eq("123 Main Street Anytown, ST 12345")
    end

    it "address and location" do
      @event.location = "Community Center"
      @event.address = "123 Main Street Anytown, ST 12345"
      expect(location_address_string(@event)).to eq("Community Center 123 Main Street Anytown, ST 12345")
    end

    it "prepend" do
      @event.location = "Community Center"
      @event.address = "123 Main Street Anytown, ST 12345"
      expect(location_address_string(@event, " at ")).to eq(" at Community Center 123 Main Street Anytown, ST 12345")
    end
  end
end
# rubocop:enable Metrics/BlockLength