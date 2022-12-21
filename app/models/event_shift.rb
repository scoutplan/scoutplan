class EventShift < ApplicationRecord
  belongs_to :event
  validates_presence_of :name

  def accepted_rsvps
    rsvps = event.rsvps.accepted
    rsvps.select { |rsvp| rsvp.event_shift_ids.include?(id) }
  end

  def attendees
    accepted_rsvps.map(&:member)
  end
end
