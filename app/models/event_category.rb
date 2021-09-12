# frozen_string_literal: true

class EventCategory < ApplicationRecord
  belongs_to :unit, optional: true
  has_many :events
  scope :default, -> { where(unit_id: nil) }
  validates_uniqueness_of :name, scope: :unit
end
