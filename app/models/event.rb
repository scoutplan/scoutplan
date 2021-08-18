class Event < ApplicationRecord
  belongs_to :unit
  belongs_to :series_parent, class_name: 'Event', optional: true
  belongs_to :event_category
  has_many   :event_rsvps
  has_many   :series_children, class_name: 'Event'
  validates_presence_of :title
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
end
