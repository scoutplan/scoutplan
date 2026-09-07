# frozen_string_literal: true

# helper methods for Locations
module LocationsHelper
  BASE_MAP_URL = "https://www.google.com/maps/embed/v1/place"
  ZOOM_LEVEL = 10
  COORDINATE_PAIR = /\A(-?\d+(?:\.\d+)?),\s*(-?\d+(?:\.\d+)?)\z/

  def location_map_src(location)
    return "" if location.map_address.blank?

    center = map_center(location)
    map_params = if center
      "q=#{escape_location_name(location.address)}&center=#{center}"
    else
      "q=#{escape_location_name(location.map_address)}"
    end

    "#{BASE_MAP_URL}?key=#{ENV.fetch("GOOGLE_API_KEY", nil)}&zoom=#{ZOOM_LEVEL}&#{map_params}"
  end

  # real columns first; map_name is only consulted for records that predate them
  def map_center(location)
    return "#{location.latitude},#{location.longitude}" if location.geocoded?
    return location.map_name if coordinates?(location)

    nil
  end

  def coordinates?(location)
    location.map_name.to_s.match?(COORDINATE_PAIR)
  end

  # gsub! mutated the string it was handed, which for location.address meant
  # stripping commas out of the record in memory
  def escape_location_name(str)
    CGI.escape(str.to_s.delete(","))
  end
end

# https://www.google.com/maps/embed/v1/place?key=snip&zoom=10&q=Eastchester+Memorial&center=40.965426,-73.808857
