# Preview all emails at http://localhost:3000/rails/mailers/event_organizer
class EventOrganizerPreview < ActionMailer::Preview
  def assignment_email
    event_organizer = EventOrganizer.first
    EventOrganizerMailer.with(event_organizer: event_organizer).assignment_email
  end
end
