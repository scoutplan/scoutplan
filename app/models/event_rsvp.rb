# frozen_string_literal: true

class EventRsvp < ApplicationRecord
  belongs_to :event
  belongs_to :user
  validates_uniqueness_of :event, scope: :user
  enum response: { declined: 0, accepted: 1, accepted_pending: 2 }
  validates_presence_of :response
end
