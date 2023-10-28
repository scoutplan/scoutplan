# frozen_string_literal: true

class SendMessageJob < ApplicationJob
  queue_as :default

  def perform(message, updated_at)
    Rails.logger.info "Performing SendMessageJob for message #{message.id}"
    return unless message.updated_at == updated_at

    message.send!
    send_broadcast(message)
  end

  private

  # TODO: move this to MessageNotification
  def send_broadcast(message)
    Turbo::StreamsChannel.broadcast_replace_later_to(
      message.unit,
      :message_folders,
      partial: "messages/sidecar",
      target:  "message_folders",
      locals:  { unit: message.unit }
    )
  end
end
