# frozen_string_literal: true

require "ostruct"

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

  def city_state
    "#{@street_address.city}, #{@street_address.state}"
  end

  # rubocop:disable Lint/SuppressedException
  def current
    api.current(@weather_city)
  rescue OpenWeatherMap::Exceptions::UnknownLocation => e
  end

  def forecast
    forecast = api.forecast(@weather_city)
    forecast&.forecast
  rescue OpenWeatherMap::Exceptions::UnknownLocation => e
  end
  # rubocop:enable Lint/SuppressedException

  def daily_forecast
    result = {}
    forecast_by_date = forecast.group_by { |conditions| conditions.time.to_date }
    forecast_by_date.map do |date, conditions|
      day_result = OpenStruct.new
      day_result.main = conditions.map(&:main).tally.min.first
      day_result.temp_min = conditions.map(&:temp_min).min
      day_result.temp_max = conditions.map(&:temp_max).max
      day_result.humidity = conditions.map(&:humidity).sum / conditions.size
      result[date] = day_result
    end
    result
  end

  def icon_class(description)
    case description
    when "Clear"
      "fa-sun"
    when "Clouds"
      "fa-cloud"
    when "Rain"
      "fa-cloud-rain"
    when "Snow"
      "fa-snowflake"
    when "Thunderstorm"
      "fa-bolt"
    when "Mist"
      "fa-smog"
    when "Windy"
      "fa-wind"
    else
      "fa-dash"
    end
  end

  def fa_icon_tag(description)
    classes = icon_class(description)

    "<i class=\"#{classes}\"></i>"
  end

  private

  def api
    @api || (@api = OpenWeatherMap::API.new(ENV.fetch("OPENWEATHER_API_KEY"), "en", "imperial"))
  end
end
