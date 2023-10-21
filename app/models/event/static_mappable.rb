# frozen_string_literal: true

module Event::StaticMappable
  extend ActiveSupport::Concern

  MAP_BASE_URL = "https://maps.googleapis.com/maps/api/staticmap"
  MAP_SIZE     = "500x300"
  MAP_ZOOM     = 10
  MAP_FILENAME = "map.png"

  def enqueue_static_map_job
    GenerateEventStaticMapJob.perform_later(id)
  end

  def generate_static_map
    return unless map_address.present?

    downloaded_image = URI.parse(map_url).open
    static_map.attach(io: downloaded_image, filename: MAP_FILENAME)
  end

  def map_url
    query = CGI.escape(map_address.gsub(",", ""))
    params = "key=#{ENV.fetch('GOOGLE_API_KEY', nil)}&center=#{query}&zoom=#{MAP_ZOOM}&size=#{MAP_SIZE}"
    params += "&markers=color:red%7C#{query}"
    "#{MAP_BASE_URL}?#{params}"
  end
end
