class Chat < ApplicationRecord
  belongs_to :chattable, polymorphic: true
  has_many :chat_messages
end
