class SendMessageJob < ApplicationJob
  queue_as :default

  def perform(message, updated_at)
    Rails.logger.warn "Performing SendMessageJob for message #{message.id}"
    return unless message.updated_at == updated_at

    message.send!
  end
end
