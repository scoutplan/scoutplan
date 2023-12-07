# frozen_string_literal: true

# a Chat models a conversation and is (as of this writing) associated 1:1
# with an Event.  It is polymorphic so that it can be associated with other
# models in the future. A Chat could be easily associated with, say, a Unit
# and treated like a general chat room. With a little more work, channels 
# could be created for a Unit and a Chat could be associated with a Channel.

# A Chattable object (e.g. an Event) must implement the following methods:
#   chat_topic
#   chat_recipients
class Chat < ApplicationRecord
  belongs_to :chattable, polymorphic: true

  has_many :chat_messages

  alias_method :messages, :chat_messages

  def participants
    # first, let's get this Chat's authors
    result = chat_messages.collect(&:author)

    # then, let's get the recipients of whatever this Chat belongs to
    # (e.g. the members planning to attend an Event)
    result << chattable.chat_recipients

    # de-dupe before returning
    result.flatten.uniq
  end

  def topic
    chattable.chat_topic || "unknown"
  end
end
