# frozen_string_literal: true

# a calendar event
class Event < ApplicationRecord
  default_scope { order(starts_at: :asc) }

  belongs_to :unit
  belongs_to :series_parent, class_name: 'Event', optional: true
  belongs_to :event_category
  has_many   :event_rsvps, dependent: :destroy
  has_many   :members, through: :event_rsvps
  has_many   :rsvp_tokens, dependent: :destroy

  has_rich_text :description

  alias_attribute :rsvps, :event_rsvps
  alias_attribute :category, :event_category

  validates_presence_of :title, :starts_at, :ends_at

  after_create :create_series, if: :repeats_until?

  enum status: { draft: 0, published: 1, cancelled: 2 }

  scope :future,        -> { where('starts_at > ?', Date.today) }
  scope :this_week,     -> { where('starts_at BETWEEN ? AND ?', Time.now, 7.days.from_now) }
  scope :upcoming,      -> { where('starts_at BETWEEN ? AND ?', 7.days.from_now, 28.days.from_now) }
  scope :rsvp_required, -> { where(requires_rsvp: true) }
  scope :today,         -> { where('starts_at BETWEEN ? AND ?', Time.zone.now.beginning_of_day, Time.zone.now.at_end_of_day) }
  scope :imminent,      -> { where('starts_at BETWEEN ? AND ?', Time.zone.now.beginning_of_day + 12.hours, Time.zone.now.at_end_of_day + 12.hours) }

  def past?
    starts_at.past?
  end

  def rsvp_open?
    requires_rsvp && starts_at > DateTime.now
  end

  def series?
    !new_record? && (series_children.count.positive? || series_siblings.count.positive?)
  end

  def rsvp_for(member)
    event_rsvps.find_by(unit_membership_id: member.id)
  end

  def rsvp_token_for(member)
    rsvp_tokens.find_by(unit_membership: member)
  end

  def rsvp_closes_at
    @rsvp_closes_at || starts_at
  end

  def series_children
    Event.where(series_parent_id: id)
  end

  def series_siblings
    return [] unless series_parent_id.present?

    Event.where(series_parent_id: series_parent_id)
  end

  def map_address
    address.blank? ? location : address
  end

  def slug
    title.parameterize
  end

  private

  # create a weekly series based on @event
  # TODO: this is super-naive: it's not idempotent, it doesn't
  # handle things like updates, etc etc
  def create_series
    new_event = dup
    new_event.series_parent = self
    new_event.repeats_until = nil

    while new_event.starts_at < repeats_until
      new_event.starts_at += 7.days
      new_event.ends_at += 7.days
      new_event.save!
      new_event = new_event.dup
    end
  end
end
