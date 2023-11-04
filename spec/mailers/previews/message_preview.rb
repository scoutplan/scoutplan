require "faker"

class MessagePreview < ActionMailer::Preview
  def message_notification
    recipient = Unit.first.members.first
    message = recipient.messages.first
    message.title = "Bring your rain gear!"
    message.body = "Weather forecast is calling for rain. Let's stay dry out there!"
    MessageMailer.with(recipient: recipient, message: message).message_notification
  end
end
