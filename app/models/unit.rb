class Unit < ApplicationRecord
  has_many :events
  has_many :event_categories
  has_many :unit_memberships
  alias_attribute :memberships, :unit_memberships
  has_many :members, through: :unit_memberships, source: :user
  validates_presence_of :name

  after_create :populate_categories

  def membership_for(user)
    memberships.find_by(user_id: user.id)
  end

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
