# frozen_string_literal: true

class Unit < ApplicationRecord
  has_many :events
  has_many :event_categories
  has_many :unit_memberships
  has_many :users, through: :unit_memberships

  validates_presence_of :name

  alias_attribute :memberships, :unit_memberships
  alias_attribute :members, :unit_memberships

  after_create :populate_categories

  has_settings do |s|
    s.key :security, defaults: { enable_magic_links: true }
    s.key :communication, defaults: { from_email: 'events@scoutplan.org' }
    s.key :locale, defaults: { time_zone: 'Easter Time (US & Canada)' }
  end

  def membership_for(user)
    members.find_by(user: user)
  end

  private

  def populate_categories
    EventCategory.default.each do |category|
      event_categories.create(
        name: category.name,
        glyph: category.glyph,
        color: category.color
      )
    end
  end
end
