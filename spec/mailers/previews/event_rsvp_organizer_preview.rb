class EventRsvpOrganizerPreview < ActionMailer::Preview
  def event_rsvp_organizer_notification
    event_rsvp = EventRsvp.first
    event_rsvp.touch
    event = event_rsvp.event
    recipient = event.unit.members.first
    EventRsvpOrganizerMailer.with(event: event, recipient: recipient).event_rsvp_organizer_notification
  end
end
