# frozen_string_literal: true

require "rubygems"
require "vcr"
require "rails_helper"

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
end

RSpec.describe WeatherService, type: :model do
  before do
    @location = FactoryBot.create(:location, address: "Paris, KY")
    @service = WeatherService.new(@location)
  end

  describe "forecast" do
    it "returns as array of conditions" do
      VCR.use_cassette("openweather_paris_ky") do
        forecast = @service.forecast
        expect(forecast).to be_a(Array)
        expect(@service.forecast.first).to be_a(OpenWeatherMap::WeatherConditions)
      end
    end
  end

  describe "current" do
    it "returns current conditions" do
      VCR.use_cassette("openweather_paris") do
        expect(@service.current.city.name).to eq("Paris")
      end
    end


    it "Cross River, NY" do
      VCR.use_cassette("openweather_cross_river") do
        location = FactoryBot.create(:location, address: "Route 35 & 121 South, Cross River, NY")
        service = WeatherService.new(location)
        expect(service.current).to be_nil
      end
    end
  end

  describe "daily_forecast" do
    it "returns a hash of daily forecasts" do
      VCR.use_cassette("openweather_paris_2") do
        expect(@service.daily_forecast).to be_a(Hash)
      end
    end
  end
end

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into nil
end
