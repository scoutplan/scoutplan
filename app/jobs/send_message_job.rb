class SendMessageJob < ApplicationJob
  queue_as :default

  def perform(message, updated_at)
    Rails.logger.warn "SendMessageJob#perform #{message.id}"
    return unless message.updated_at == updated_at

    Rails.logger.warn "Sending #{message.id}"
    message.send!
  end
end
