# frozen_string_literal: true

# encapsulates the OpenWeatherMap API
class WeatherService
  def initialize(arg)
    @location = arg.primary_location if arg.is_a?(Event)
    @location = arg if arg.is_a?(Location)
    return unless @location.present?

    @street_address = @location.street_address
    return unless @street_address.present?

    @weather_city = "#{@street_address.city}, #{@street_address.state}, US"
  end

  def weather_available?
    @location.present? && @street_address.present? && @weather_city.present?
  end

  def current
    api.current(@weather_city)
  rescue OpenWeatherMap::Exceptions::UnknownLocation => e
  end

  def forecast
    forecast = api.forecast(@weather_city)
    forecast&.forecast
  rescue OpenWeatherMap::Exceptions::UnknownLocation => e
  end

  private

  def api
    @api || (@api = OpenWeatherMap::API.new(ENV.fetch("OPENWEATHER_API_KEY"), "en", "imperial"))
  end
end
