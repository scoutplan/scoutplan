# frozen_string_literal: true

# aynchronous job to send notifications when a new chat message is posted
class ChatNotifier < ApplicationJob
  def perform(chat_message)
    chat = chat_message.chat

    chat.participants.each do |member|
      next unless member.smsable?
      next unless Flipper.enabled?(:chat_notifications, member)

      ChatMemberTexter.new(member, chat_message).send_message
    end
  end
end
