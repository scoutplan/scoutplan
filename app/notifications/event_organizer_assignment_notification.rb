# frozen_string_literal: true

# To deliver this notification:
#
# EventOrganizerAssignmentNotification.with(event: @event, member: @member).deliver_later(member)
class EventOrganizerAssignmentNotification < Noticed::Base
  deliver_by :database
  deliver_by :email, mailer: "EventOrganizerMailer", method: :assignment_email

  param :event_organizer
end
