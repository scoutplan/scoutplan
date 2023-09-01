# frozen_string_literal: true

class EventCategory < ApplicationRecord
  belongs_to :unit, optional: true
  has_many :events
  scope :seeds, -> { where(unit_id: nil) }
  validates_uniqueness_of :name, scope: :unit

  def show_weather?
    name != "Troop Meeting"
  end
end
