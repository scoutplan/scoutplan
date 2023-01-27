# frozen_string_literal: true

# Texter for notifying members of new chat messages
class ChatMemberTexter < ApplicationTexter
  def initialize(member, chat_message)
    @member = member
    @chat_message = chat_message
    super
  end

  def to
    @member.phone
  end

  def body
    renderer.render(
      template: "member_texter/chat_message",
      format: "text",
      assigns: { chat_message: @chat_message, member: @member, unit: @member.unit, event: @chat_message.chat.chattable }
    )
  end
end
