# frozen_string_literal: true

class MessageMailbox < ApplicationMailbox
  def process
    @message = inbound_email.evaluator.message
    return unless @message.present?

    notification = MessageReplyNotification.with(inbound_email: inbound_email, message: @message)
    notification.deliver_later(@message.author)
  end
end
