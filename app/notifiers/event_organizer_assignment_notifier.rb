class EventOrganizerAssignmentNotifier < Noticed::Event
  deliver_by :email do |config|
    config.mailer = "EventOrganizerMailer"
    config.method = :assignment_email
    config.if = :email?
  end

  required_param :event_organizer
end
