class MessageRecipient < ApplicationRecord
  belongs_to :message
  belongs_to :message_receivable, polymorphic: true
end
