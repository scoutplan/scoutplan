class EventRsvp < ApplicationRecord
  belongs_to :event
  belongs_to :user
  validates_uniqueness_of :event, scope: :user
  enum response: { accepted: 0, declined: 1 }
end
