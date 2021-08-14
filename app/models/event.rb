class Event < ApplicationRecord
  belongs_to :unit
  has_many   :event_rsvps
  validates_presence_of :title

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
