# frozen_string_literal: true

require "rails_helper"

describe LocationsHelper, type: :helper do
  let(:unit) { FactoryBot.create(:unit) }

  def location(**attrs)
    FactoryBot.build(:location, unit: unit, **attrs)
  end

  describe "#escape_location_name" do
    it "does not mutate the string it is given" do
      address = +"Reservation Rd, Pound Ridge, NY"

      helper.escape_location_name(address)

      expect(address).to eq("Reservation Rd, Pound Ridge, NY")
    end

    it "strips commas and escapes" do
      expect(helper.escape_location_name("Pound Ridge, NY")).to eq("Pound+Ridge+NY")
    end

    it "tolerates nil" do
      expect(helper.escape_location_name(nil)).to eq("")
    end
  end

  describe "#map_center" do
    it "prefers the coordinate columns" do
      subject = location(latitude: 41.256, longitude: -73.573, map_name: "Ward Pound Ridge")

      expect(helper.map_center(subject)).to eq("41.256,-73.573")
    end

    it "falls back to a coordinate pair stored in map_name" do
      subject = location(latitude: nil, longitude: nil, map_name: "41.256,-73.573")

      expect(helper.map_center(subject)).to eq("41.256,-73.573")
    end

    it "is nil when there are no coordinates anywhere" do
      subject = location(latitude: nil, longitude: nil, map_name: "Ward Pound Ridge")

      expect(helper.map_center(subject)).to be_nil
    end
  end

  describe "#location_map_src" do
    # map_address falls back to name, and name is required, so this guard only
    # trips for a record with nothing in it at all
    it "is blank when there is nothing to map" do
      subject = location(name: nil, address: nil, map_name: nil)

      expect(helper.location_map_src(subject)).to eq("")
    end

    it "centres on the coordinates when they are known" do
      subject = location(address: "Reservation Rd, Pound Ridge, NY",
        latitude: 41.256, longitude: -73.573)

      expect(helper.location_map_src(subject)).to include("center=41.256,-73.573")
    end

    it "uses the address as the query when they are not" do
      subject = location(name: "Ward Pound Ridge", address: "Reservation Rd, Pound Ridge, NY",
        map_name: nil, latitude: nil, longitude: nil)

      src = helper.location_map_src(subject)

      expect(src).to include("q=")
      expect(src).not_to include("center=")
    end
  end

  describe Location do
    it "reports geocoded? only with both coordinates" do
      expect(location(latitude: 41.256, longitude: -73.573)).to be_geocoded
      expect(location(latitude: 41.256, longitude: nil)).not_to be_geocoded
      expect(location(latitude: nil, longitude: nil)).not_to be_geocoded
    end

    it "rejects out-of-range coordinates" do
      expect(location(latitude: 91, longitude: 0)).not_to be_valid
      expect(location(latitude: 0, longitude: 181)).not_to be_valid
      expect(location(latitude: 41.256, longitude: -73.573)).to be_valid
    end
  end
end
