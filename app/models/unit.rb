# frozen_string_literal: true

# a Troop, Pack, Post, Lodge, or Crew
class Unit < ApplicationRecord
  has_many :events
  has_many :event_categories
  has_many :unit_memberships
  has_many :users, through: :unit_memberships
  has_one_attached :logo

  validates_presence_of :name

  alias_attribute :memberships, :unit_memberships
  alias_attribute :members, :unit_memberships

  after_create :populate_categories

  has_settings do |s|
    s.key :security, defaults: { enable_magic_links: true }
    s.key :appearance, defaults: { main_color: '#003F87' }
    s.key :communication, defaults: {
      from_email: 'events@scoutplan.org',
      weekly_digest: 'every Sunday at 6:00 AM',
      daily_reminder: 'daily at 6:00 AM'
    }
    s.key :locale, defaults: { time_zone: 'Eastern Time (US & Canada)' }
    s.key :security, defaults: { enable_magic_links: true }
    s.key :utilities, defaults: { fire_scheduled_tasks: false }
  end

  def membership_for(user)
    members.find_by(user: user)
  end

  def slug
    [name, location].join(' ').parameterize
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
