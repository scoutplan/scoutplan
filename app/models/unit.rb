# frozen_string_literal: true

# a Troop, Pack, Post, Lodge, or Crew.
#
class Unit < ApplicationRecord
  has_many :events
  has_many :event_categories
  has_many :unit_memberships
  has_many :users, through: :unit_memberships
  has_many :news_items
  has_many :tasks, as: :taskable
  has_one_attached :logo

  validates_presence_of :name

  alias_attribute :memberships, :unit_memberships
  alias_attribute :members, :unit_memberships

  after_create :populate_categories

  has_settings do |s|
    s.key :security, defaults: { enable_magic_links: true }
    s.key :communication, defaults: { from_email: "reminders@scoutplan.org" }
    s.key :appearance, defaults: { main_color: "#003F87" }
    s.key :locale, defaults: {
      time_zone: "Eastern Time (US & Canada)",
      meeting_location: nil,
      meeting_address: nil
    }
    s.key :utilities, defaults: { fire_scheduled_tasks: false }
  end

  def to_param
    [id, name, location].join(" ").parameterize
  end

  def membership_for(user)
    members.includes(:parent_relationships, :child_relationships).find_by(user: user)
  end

  def planner
    Planner.new(self)
  end

  def default_event_category
    categories.first
  end

  private

  # TODO: move this somewhere else
  def populate_categories
    EventCategory.seeds.each do |category|
      event_categories.create(
        name: category.name,
        glyph: category.glyph,
        color: category.color
      )
    end
  end
end
