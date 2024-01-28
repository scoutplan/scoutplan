class EventOrganizerAssignmentNotifier < Noticed::Event
  deliver_by :email, mailer: "EventOrganizerMailer", method: :assignment_email

  required_param :event_organizer
end
