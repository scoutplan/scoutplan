# frozen_string_literal: true

module Event::Replyable
  extend ActiveSupport::Concern

  JOIN_LEAD_TIME = 15.minutes.freeze

  def email
    "event-#{token}@#{ENV.fetch('EMAIL_DOMAIN')}"
  end
end
