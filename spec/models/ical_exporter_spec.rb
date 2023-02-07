# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe IcalExporter, type: :model do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    Time.zone = @unit.settings(:locale).time_zone
    @event = FactoryBot.create(:event, unit: @unit, starts_at: 24.hours.from_now, ends_at: 25.hours.from_now)
    @exporter = IcalExporter.new(@member, @event)
  end

  describe "timezones" do
    it "publishes events in the local timezone" do
      @ical_event = @exporter.to_ical
      expect(@ical_event.dtstart).to eq(@event.starts_at.in_time_zone)
    end
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
    it "includes the location and address when both are present" do
      @ical_event = @exporter.to_ical
      expect(@ical_event.location).to eq(@event.full_address)
    end
  end
end
# rubocop:enable Metrics/BlockLength
