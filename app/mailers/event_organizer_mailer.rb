# frozen_string_literal: true

# Mailer for event organizers
class EventOrganizerMailer < ScoutplanMailer
  layout "basic_mailer"

  def assignment_email
    @event_organizer = params[:event_organizer]
    @event  = @event_organizer.event
    @unit   = @event.unit
    @member = @event_organizer.unit_membership
    @user   = @member.user
    mail(
      to: @user.email,
      from: unit_from_address_with_name,
      reply_to: "event-#{@event.uuid}@#{ENV.fetch('EMAIL_DOMAIN')}",
      subject: "[#{@unit.name}] You've been added as an organizer for #{@event.title}"
    )
  end
end
