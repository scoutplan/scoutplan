# frozen_string_literal: true

# An ActiveJob for sending email asynchronously
class SendMessageJob < ApplicationJob
  queue_as :default

  def perform(message)
    return unless message.send_now?

    message.recipients.each do |recipient|
      next unless Flipper.enabled? :messages, recipient

      MemberNotifier.new(recipient).send_message(message)
    end

    message.mark_as_sent!

    Turbo::StreamsChannel.broadcast_replace_later_to(
      message.unit,
      :message_folders,
      partial: "messages/sidecar",
      target: "message_folders",
      locals: { unit: message.unit }
    )
  end
end
