# frozen_string_literal: true

# represents a place (typically for an Event)
# :departure, :arrival, :activity are valid keys
class Location < ApplicationRecord
  # belongs_to :locatable, polymorphic: true

  # ensure we don't duplicate keys
  validates_uniqueness_of :key, scope: [:locatable_type, :locatable_id]

  def full_address
    [name, address, city, state_and_zip].compact.join(", ").strip.gsub(/\,$/, "").gsub(" , ", " ")
  end

  def state_and_zip
    [state, postal_code].compact.join(" ").strip
  end

  def display_name
    name || address || ""
  end
end
