# frozen_string_literal: true

module Event::Onlineable
  extend ActiveSupport::Concern

  JOIN_LEAD_TIME = 15.minutes.freeze

  def joinable?
    starts_at < JOIN_LEAD_TIME.from_now && ends_at.future?
  end

  def hostname
    URI.parse(website).host
  end
end
