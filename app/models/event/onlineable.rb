# frozen_string_literal: true

module Event::Onlineable
  extend ActiveSupport::Concern

  JOIN_LEAD_TIME = 15.minutes.freeze

  included do
    validate :valid_website_url?
  end

  def joinable?
    starts_at < JOIN_LEAD_TIME.from_now && ends_at.future?
  end

  def hostname
    URI.parse(website).host
  end

  def valid_website_url?
    return false if website.blank?

    uri = URI.parse(website)
    uri.host.present?
  rescue URI::InvalidURIError
    errors.add(:website, "Invalid URL")
  end
end
