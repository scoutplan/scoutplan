# frozen_string_literal: true

# represents a place (typically for an Event)
# :departure, :arrival, :activity are valid keys
class Location < ApplicationRecord
  belongs_to :unit
  has_many :event_locations, dependent: :destroy

  def full_address
    [name, address].compact.join(", ").strip.gsub(/\,$/, "").gsub(" , ", " ")
  end

  def display_name
    name || map_name || address || ""
  end
end
