# frozen_string_literal: true

class EventInvitationMailer < ScoutplanMailer
  helper MagicLinksHelper

  layout "event_invitation_mailer"

  def event_invitation_email
    @event = @unit.events.find(params[:event_id])
    attachments[@event.ical_filename] = ics_attachment
    mail(
      to: email_address_with_name(@member.email, @member.full_display_name),
      from: unit_from_address_with_name,
      subject: subject
    )
  end

  private

  def ics_attachment
    {
      mime_type: "multipart/mixed",
      content_type: "text/calendar; method=REQUEST; charset=UTF-8; component=VEVENT",
      content_disposition: "attachment; filename=event.ics",
      content: @event.to_ical
    }
  end

  def subject
    "#{@unit.name} is inviting you to #{@event.title}"
  end
end
