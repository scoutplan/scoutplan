# frozen_string_literal: true

# join Model between Events and Location
class EventLocation < ApplicationRecord
  belongs_to :event
  belongs_to :location
  validates_uniqueness_of :location_type, scope: [:event, :location]
end
