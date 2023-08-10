# frozen_string_literal: true

# a Troop, Pack, Post, Lodge, or Crew.
#
class Unit < ApplicationRecord
  include Seasons
  has_one :payment_account
  has_many :events
  has_many :event_categories
  has_many :unit_memberships
  has_many :users, through: :unit_memberships
  has_many :locations, through: :events
  has_many :news_items
  has_many :tasks, as: :taskable
  has_many :locations
  has_many :packing_lists, dependent: :destroy
  has_many :photos, dependent: :destroy
  has_many :payments, through: :events
  has_many :wiki_pages
  has_one_attached :logo

  validates_presence_of :name
  validates_presence_of :location
  validates_presence_of :slug
  validates_uniqueness_of :email
  validates_uniqueness_of :slug

  alias_attribute :memberships, :unit_memberships
  alias_attribute :members, :unit_memberships

  after_create :populate_categories
  before_validation :generate_slug

  has_settings do |s|
    s.key :security, defaults: { enable_magic_links: true }
    s.key :communication, defaults: {
      digest: true,
      rsvp_nag: true,
      daily_reminder: true
    }
    s.key :appearance, defaults: { main_color: "#003F87" }
    s.key :locale, defaults: {
      time_zone: "Eastern Time (US & Canada)",
      meeting_location: nil,
      meeting_address: nil
    }
    s.key :utilities, defaults: { fire_scheduled_tasks: false }
  end

  def attachments
    ActiveStorage::Attachment.includes(:blob).with_all_variant_records.where(record_type: "Event", record_id: events.collect(&:id))
  end

  def from_address
    slug + "@" + ENV["EMAIL_DOMAIN"]
  end

  def messages
    # members.collect(&:messages)
    Message.where(author_id: members.collect(&:id))
  end

  def membership_for(user)
    members.includes(:parent_relationships, :child_relationships).find_by(user: user)
  end

  def payments_enabled?
    payment_account.present? && payment_account.active?
  end

  def planner
    Planner.new(self)
  end

  def default_event_category
    categories.first
  end

  def short_name
    name.split.map { |word| word.numeric? ? word : word.first }.join
  end

  def time_zone
    settings(:locale).time_zone
  end

  def business_hours
    [9, 18]
  end

  # given a datetime, returns the nearest datetime that is within business hours
  def in_business_hours(datetime)
    if datetime.in_time_zone(time_zone).hour < business_hours.first
      datetime.in_time_zone(time_zone).change(hour: business_hours.first, min: 0, sec: 0).utc
    elsif datetime.in_time_zone(time_zone).hour >= business_hours.last
      datetime.in_time_zone(time_zone).change(hour: business_hours.last, min: 0, sec: 0).utc
    else
      datetime
    end
  end

  # def to_param
  #   [id, name, location].join(" ").parameterize
  # end

  def to_s
    name
  end

  # acts like .update, but for settings as defined at the top of the class
  def update_settings(params)
    params.each do |key, value|
      settings(key.to_sym).update!(value)
    end
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

  def generate_slug
    return if slug.present? || name.blank?

    candidate = base = name.parameterize
    candidate = base + "-#{rand(100)}" while Unit.where(slug: candidate).exists?

    update(slug: candidate)
  end
end
