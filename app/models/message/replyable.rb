# frozen_string_literal: true

module Message::Replyable
  extend ActiveSupport::Concern

  def email
    # "message-#{token}@#{ENV.fetch('EMAIL_DOMAIN')}"
    author.email
  end
end
