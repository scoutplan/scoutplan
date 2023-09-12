# frozen_string_literal: true

require "faker"

class MessagePreview < ActionMailer::Preview
  def message_notification
    url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    recipient = Unit.first.members.first
    message = recipient.messages.first
    message.body = Faker::Lorem.paragraphs(number: 3).join("\n\n")
    message.body.concat("\n\n<a href='#{url}'>#{url}</a>")
    MessageMailer.with(recipient: recipient, message: message).message_notification
  end
end
