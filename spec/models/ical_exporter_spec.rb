# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe IcalExporter, type: :model do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @event = FactoryBot.create(:event, unit: @member.unit)
    @exporter = IcalExporter.new(@member, @event)
  end

  describe "event name" do
    it "prepends the unit's short name" do
      @ical_event = @exporter.to_ical
      expect(@ical_event.summary).to start_with(@unit.short_name)
    end

    it "appends DRAFT events" do
      @exporter.event.status = :draft
      @ical_event = @exporter.to_ical
      expect(@ical_event.summary).to end_with("(DRAFT)")
    end

    it "appends CANCELLED events" do
      @exporter.event.status = :cancelled
      @ical_event = @exporter.to_ical
      expect(@ical_event.summary).to end_with("(CANCELLED)")
    end
  end

  describe "location" do
    it "includes the location field when present" do
      @exporter.event.location = "A location"
      @ical_event = @exporter.to_ical
      expect(@ical_event.location).to eq(@event.location)
    end

    it "includes the address when present" do
      @event.address = "An address"
      @ical_event = @exporter.to_ical
      expect(@ical_event.location).to eq(@event.address)
    end

    it "includes the location and address when both as present" do
      @event.location = "A location"
      @event.address = "An address"
      @ical_event = @exporter.to_ical
      expect(@ical_event.location).to eq("#{@event.location} #{@event.address}")
    end
  end
end
# rubocop:enable Metrics/BlockLength