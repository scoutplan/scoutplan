# frozen_string_literal: true

require "rails_helper"

RSpec.describe WeatherService, type: :model do
  before do
    @location = FactoryBot.create(:location, address: "Paris, KY")
    @service = WeatherService.new(@location)
  end

  describe "forecast" do
    it "returns as array of conditions" do
      forecast = @service.forecast
      expect(forecast).to be_a(Array)
      expect(@service.forecast.first).to be_a(OpenWeatherMap::WeatherConditions)
    end
  end

  describe "current" do
    it "returns current conditions" do
      expect(@service.current.city.name).to eq("Paris")
    end

    it "Cross River, NY" do
      location = FactoryBot.create(:location, address: "Route 35 & 121 South, Cross River, NY")
      service = WeatherService.new(location)
      expect(service.current).to be_nil
    end
  end

  describe "daily_forecast" do
    it "returns a hash of daily forecasts" do
      expect(@service.daily_forecast).to be_a(Hash)
    end
  end
end
