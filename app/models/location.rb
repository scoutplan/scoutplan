# frozen_string_literal: true

# represents a place (typically for an Event)
class Location < ApplicationRecord
  belongs_to :locatable, polymorphic: true

  # ensure we don't duplicate keys
  validates_uniqueness_of :key, scope: [:locatable_type, :locatable_id]

  def full_address
    [name, address, city, state, postal_code].join(" ")
  end
end
