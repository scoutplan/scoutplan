class ConversationContext < ApplicationRecord
  validates_uniqueness_of :identifier
end
