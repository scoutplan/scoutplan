class ChatMessage < ApplicationRecord
  belongs_to :chat
  belongs_to :author, class_name: "UnitMembership"

  def author_name
    author.short_display_name
  end
end
