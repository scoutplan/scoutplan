# frozen_string_literal: true

class EventInvitationMailer < ScoutplanMailer
  before_action :find_event

  helper MagicLinksHelper

  layout "event_invitation_mailer"

  def event_invitation_email
    attachments[@event.ical_filename] = ics_attachment
    mail(to: to_address, from: from_address, subject: subject)
    persist_invitation
  end

  private

  def find_event
    @event = @unit.events.find(params[:event_id])
  end

  def from_address
    email_address_with_name(@event.email, @unit.name)
  end

  def ics_attachment
    {
      mime_type:           "multipart/mixed",
      content_type:        "text/calendar; method=REQUEST; charset=UTF-8; component=VEVENT",
      content_disposition: "attachment; filename=#{@event.ical_filename}",
      content:             @event.to_ical(@member)
    }
  end

  def persist_invitation
    EventInvitation.find_or_create_by!(event: @event, unit_membership: @member)
  end

  def subject
    "[#{@unit.name}] Invitation to the #{@event.title} on #{@event.starts_at.strftime('%b %-d')}"
  end

  def to_address
    email_address_with_name(@member.email, @member.full_display_name)
  end
end
