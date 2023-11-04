require "faker"

class MessagePreview < ActionMailer::Preview
  def message_notification
    recipient = Unit.first.members.first
    message = recipient.messages.first
    message.title = "I can't believe it's not butter!"
    message.body = Faker::Lorem.paragraphs(number: 3).join("\n\n")
    MessageMailer.with(recipient: recipient, message: message).message_notification
  end
end
