# frozen_string_literal: true

require "rails_helper"

describe EventLocation do
  include ActiveJob::TestHelper

  let(:unit) { FactoryBot.create(:unit) }
  let(:event) { FactoryBot.create(:event, unit: unit) }

  def attach(type)
    FactoryBot.create(:event_location, event: event,
                                       location: FactoryBot.create(:location, unit: unit),
                                       location_type: type)
  end

  describe "location_type enum" do
    it "exposes exactly the three place types" do
      expect(described_class.location_types.keys).to eq(%w[departure arrival activity])
    end

    it "no longer accepts online, which lives on the event" do
      record = FactoryBot.build(:event_location, event: event, location_type: "online")

      expect(record).not_to be_valid
      expect(record.errors[:location_type]).to be_present
    end

    it "rejects an unknown type without raising" do
      record = FactoryBot.build(:event_location, event: event, location_type: "test")

      expect { record.valid? }.not_to raise_error
      expect(record).not_to be_valid
    end

    it "provides predicates and scopes" do
      attach("departure")

      expect(described_class.departure.count).to eq(1)
      expect(described_class.departure.first).to be_departure
    end
  end

  describe ".in_display_order" do
    it "orders departure, arrival, activity regardless of insertion order" do
      event.event_locations.destroy_all
      attach("activity")
      attach("departure")
      attach("arrival")

      expect(event.event_locations.in_display_order.map(&:location_type))
        .to eq(%w[departure arrival activity])
    end

    it "does not drop types the way a hardcoded list could" do
      event.event_locations.destroy_all
      described_class.location_types.keys.each { |t| attach(t) }

      expect(event.event_locations.in_display_order.count)
        .to eq(described_class.location_types.size)
    end
  end

  describe "static map regeneration" do
    it "enqueues one job per event, not one per location" do
      event.event_locations.destroy_all

      expect do
        event.update!(event_locations_attributes: [
          {location_type: "departure", location_id: FactoryBot.create(:location, unit: unit).id},
          {location_type: "arrival", location_id: FactoryBot.create(:location, unit: unit).id},
          {location_type: "activity", location_id: FactoryBot.create(:location, unit: unit).id}
        ])
      end.to change { enqueued_jobs.count { |j| j["job_class"] == "GenerateEventStaticMapJob" } }.by(1)
    end
  end
end
