# frozen_string_literal: true

# Rails Mailer for sending event invitations via email

require "icalendar"

class EventInvitationMailer < ScoutplanMailer
  helper MagicLinksHelper

  layout "event_invitation_mailer"

  # Sends an email that includes an event.ics attachment, so that the member's
  # mail client will treat it like a calendar invitation
  def event_invitation_email
    @event = @unit.events.find(params[:event_id])

    # Generate the iCalendar object
    cal = Icalendar::Calendar.new
    cal.append_custom_property("METHOD", "REQUEST")
    exporter = IcalExporter.new(@member)
    exporter.event = @event
    cal.add_event(exporter.to_ical)

    # Add the event.ics attachment
    attachments["event.ics"] = {
      mime_type: 'multipart/mixed', ## important because we are sending html and text files for the body in addition to the actual attachment
      content_type: 'text/calendar; method=REQUEST; charset=UTF-8; component=VEVENT',
      content_disposition: 'attachment; filename=event.ics',
      content: cal.to_ical
    }

    # Send the email
    mail(to: @member.email,
         from: @unit.from_address,
         subject: "#{@unit.name} is inviting you to #{@event.title}")
  end
end