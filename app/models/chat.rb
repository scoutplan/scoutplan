# frozen_string_literal: true

class Chat < ApplicationRecord
  belongs_to :chattable, polymorphic: true

  has_many :chat_messages

  alias_attribute :messages, :chat_messages

  def participants
    result = chat_messages.collect(&:author)
    result << chattable.rsvps.accepted.select { |r| r.member.smsable? }.collect(&:member) if chattable.is_a?(Event)
    result.flatten.uniq
  end

  def topic
    return "#{chattable.title} on #{chattable.starts_at.strftime("%b %d")}" if chattable.is_a?(Event)

    "Chat"
  end
end
