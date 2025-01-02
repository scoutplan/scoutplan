# frozen_string_literal: true

class AddressBookEventEntry < AddressBookEntry
  attr_reader :event

  def initialize(event)
    @event = event
    super()
  end

  def key
    "event_#{event.id}"
  end

  def name
    event.title
  end

  def description
    count = event.event_rsvps.accepted.count
    "#{count} attendee"
  end
end
