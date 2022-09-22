# frozen_string_literal: true

# join model for Event to Location
class EventLocation < ApplicationRecord
  belongs_to :event
  belongs_to :location
  validates_uniqueness_of :key, scope: [:event, :location] # prevent dupes
end
