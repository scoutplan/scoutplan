# frozen_string_literal: true

# a ChatMessage is a message sent in a chat
class ChatMessage < ApplicationRecord
  include Turbo::Broadcastable
  belongs_to :chat
  belongs_to :author, class_name: "UnitMembership"
  # after_create_commit :broadcast_later

  def author_name
    author.short_display_name
  end

  private

  def broadcast_later
    broadcast_prepend_later_to "chat_#{chat.id}", :chat_messages
  end
end

# https://www.honeybadger.io/blog/chat-app-rails-actioncable-turbo/
# https://www.rubydoc.info/github/hotwired/turbo-rails/Turbo/Broadcastable
# https://www.hotrails.dev/turbo-rails/turbo-streams