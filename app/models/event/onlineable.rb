# frozen_string_literal: true

module Event::Onlineable
  extend ActiveSupport::Concern

  JOIN_LEAD_TIME = 15.minutes.freeze

  included do
    validate :valid_online_url?
  end

  # online? reads the events.online boolean rather than the presence of a URL:
  # an organiser can commit to an online event before they have the link.
  # online_url is therefore optional, and mutually exclusive with locations.
  def online_link?
    online? && online_url.present?
  end

  def joinable?
    starts_at < JOIN_LEAD_TIME.from_now && ends_at.future?
  end

  def hostname
    URI.parse(online_url).host
  end

  def valid_online_url?
    return if online_url.blank?

    errors.add(:online_url, "Invalid URL") if URI.parse(online_url).host.blank?
  rescue URI::InvalidURIError
    errors.add(:online_url, "Invalid URL")
  end
end
