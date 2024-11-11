# frozen_string_literal: true

module Event::Onlineable
  extend ActiveSupport::Concern

  JOIN_LEAD_TIME = 15.minutes.freeze

  included do
    validate :valid_online_url?
  end

  def online?
    online_url.present?
  end

  def joinable?
    starts_at < JOIN_LEAD_TIME.from_now && ends_at.future?
  end

  def online_url
    online_location&.url || website
  end

  def online_location
    @online_location || event_locations.find_by(location_type: "online")
  end

  def hostname
    URI.parse(online_url).host
  end

  def valid_online_url?
    return false if online_url.blank?

    uri = URI.parse(online_url)
    uri.host.present?
  rescue URI::InvalidURIError
    errors.add(:online_url, "Invalid URL")
  end
end
