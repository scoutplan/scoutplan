# frozen_string_literal: true

require "street_address"

# represents a place (typically for an Event)
# :departure, :arrival, :activity are valid keys
class Location < ApplicationRecord
  belongs_to :unit
  has_many :event_locations, dependent: :destroy
  has_rich_text :organizer_notes
  validates_presence_of :name

  def full_address
    return map_name.strip.gsub(/\,$/, "").gsub(" , ", " ") if map_name.present?

    display_address
  end

  def map_address
    [map_name || name, address].compact.join(", ").strip.gsub(/\,$/, "").gsub(" , ", " ")
  end

  def display_name
    name || map_name || address || ""
  end

  # for use in dropdowns
  def display_address
    [name, address].compact.join(", ").strip.gsub(/\,$/, "").gsub(" , ", " ")
  end

  def mappable?
    map_name.present? || address.present?
  end

  def street_address
    @street_address ||= StreetAddress::US.parse(address) || street_address_from_string(address)
  end

  def street_address_from_string(str)
    return nil if str.blank?

    parts = str.split(",").map(&:strip)
    return nil if parts.size < 2

    StreetAddress::US::Address.new(city: parts[0], state: parts[1])
  end
end
