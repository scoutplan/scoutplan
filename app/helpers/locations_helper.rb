# frozen_string_literal: true

# helper methods for Locations
module LocationsHelper
  BASE_MAP_URL = "https://www.google.com/maps/embed/v1/place"
  ZOOM_LEVEL = 10

  def location_map_src(location)
    map_params = if coordinates?(location)
                   "q=#{escape_location_name(@location.address)}&center=#{@location.map_name}"
                 else
                   "q=#{escape_location_name(@location.map_name || @location.address)}"
                 end
    BASE_MAP_URL + "?key=#{ENV.fetch('GOOGLE_API_KEY')}" + "&zoom=#{ZOOM_LEVEL}" + "&#{map_params}"
  end

  def coordinates?(location)
    location.map_name =~ /^(-?\d+(\.\d+)?),\s*(-?\d+(\.\d+)?)$/
  end

  def escape_location_name(str)
    str.gsub!(",", "")
    CGI.escape(str)
  end
end

# https://www.google.com/maps/embed/v1/place?key=snip&zoom=10&q=Eastchester+Memorial&center=40.965426,-73.808857