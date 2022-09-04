# frozen_string_literal: true

require "rails_helper"

RSpec.describe IcalExporter, type: :model do
  before do
    @member = FactoryBot.create(:member)
    @exporter = IcalExporter.new(@member)
  end

  describe "location" do
    it "includes the location field when present" do
      @event = FactoryBot.create(:event, :with_location)
      @exporter.event = @event
      ical_event = @exporter.to_ical
      expect(ical_event.location).to eq(@event.location)
    end

    it "includes the address when present" do
      @event = FactoryBot.create(:event, :with_address)
      @exporter.event = @event
      ical_event = @exporter.to_ical
      expect(ical_event.location).to eq(@event.address)
    end

    it "includes the location and address when both as present" do
      @event = FactoryBot.create(:event, :with_location, :with_address)
      @exporter.event = @event
      ical_event = @exporter.to_ical
      expect(ical_event.location).to eq("#{@event.location} #{@event.address}")
    end

    it "appends DRAFT events" do
      @event = FactoryBot.create(:event, :with_location, :with_address)
      @exporter.event = @event
      @event.status = :draft
      ical_event = @exporter.to_ical
      expect(ical_event.summary).to end_with("(DRAFT)")
    end

    it "appends CANCELLED events" do
      @event = FactoryBot.create(:event, :with_location, :with_address)
      @exporter.event = @event
      @event.status = :cancelled
      ical_event = @exporter.to_ical
      expect(ical_event.summary).to end_with("(CANCELLED)")
    end
  end
end
