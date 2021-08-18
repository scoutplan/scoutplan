class Unit < ApplicationRecord
  has_many :events
  has_many :event_categories
  has_many :unit_memberships
  has_many :members, through: :unit_memberships
  validates_presence_of :name

  after_create :populate_categories

private
  def populate_categories
    EventCategory.default.each do |category|
      self.event_categories.create(
        name: category.name,
        glyph: category.glyph,
        color: category.color,
      )
    end
  end
end
