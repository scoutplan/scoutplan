class Event < ApplicationRecord
  belongs_to :unit
  belongs_to :series_parent, class_name: 'Event', optional: true
  # has_many   :series_children, class_name: 'Event', foreign_key: :series_parent_id
  belongs_to :event_category
  has_many   :event_rsvps
  alias_attribute :rsvps, :event_rsvps
  has_many   :series_children, class_name: 'Event'
  validates_presence_of :title, :starts_at, :ends_at
  default_scope { order(starts_at: :asc) }
  alias_attribute :category, :event_category

  def past?
    starts_at.compare_with_coercion(Date.today) == -1
  end

  def rsvp_open?
    requires_rsvp
  end

  def has_rsvp_for?(user)
    event_rsvps.count > 0
  end

  def series?
    !new_record? && (series_children.count > 0 || series_siblings.count > 0)
  end

  def series_children
    Event.where(series_parent_id: id)
  end

  def series_siblings
    return [] unless series_parent_id.present?
    Event.where(series_parent_id: series_parent_id)
  end
end
