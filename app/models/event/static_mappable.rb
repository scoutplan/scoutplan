# frozen_string_literal: true

module Event::StaticMappable
  extend ActiveSupport::Concern

  included do
    # the memo below suppresses duplicate enqueues within one save cycle; clear
    # it on each save so a long-lived instance can still queue again later
    before_save { @static_map_job_enqueued = false }
  end

  MAP_BASE_URL = "https://maps.googleapis.com/maps/api/staticmap"
  MAP_SIZE = "500x300"
  MAP_ZOOM = 10
  MAP_FILENAME = "map.png"

  def enqueue_static_map_job
    GenerateEventStaticMapJob.perform_later(id)
  end

  # an event has exactly one static map, so saving several locations in one go
  # should not queue several regenerations
  def enqueue_static_map_job_once
    return if @static_map_job_enqueued

    @static_map_job_enqueued = true
    enqueue_static_map_job
  end

  def generate_static_map
    return unless map_address.present?

    downloaded_image = URI.parse(map_url).open
    static_map.attach(io: downloaded_image, filename: MAP_FILENAME)
  end

  def map_url
    query = CGI.escape(map_address.delete(","))
    params = "key=#{ENV.fetch("GOOGLE_API_KEY", nil)}&center=#{query}&zoom=#{MAP_ZOOM}&size=#{MAP_SIZE}"
    params += "&markers=color:red%7C#{query}"
    "#{MAP_BASE_URL}?#{params}"
  end
end
