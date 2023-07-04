# frozen_string_literal: true

# The Mailer class for sending email relating to specific events
#
class EventMailer < ScoutplanMailer
  helper MagicLinksHelper

  def cancellation_email
    @member = params[:member]
    @event = params[:event]
    @note = params[:note]
    mail(
      to: @member.email,
      from: unit_from_address_with_name,
      subject: "#{@unit.name} #{@event.title} Cancelled"
    )
  end

  def token_invitation_email
    @token = params[:token]
    @event = @token.event
    @user = @token.user
    @url = rsvp_response_url(@token.value)
    mail(
      to: @user.email,
      from: unit_from_address_with_name,
      subject: "#{@unit.name} Event Invitation: #{@event.title}"
    )
  end

  def bulk_publish_email
    @events = Event.find(params[:event_ids])
    @user = params[:user]
    @url = unit_events_url(@unit)
    mail(to: @user.email,
         from: unit_from_address_with_name,
         subject: "#{@unit.name}: New Events Have Been Added to the Calendar")
  end

  def rsvp_confirmation_email
    @rsvp = params[:rsvp]
    user = @rsvp.user
    mail(to: email_address_with_name(user.email, user.full_display_name),
         from: unit_from_address_with_name,
         subject: "#{@rsvp.unit.name} — Your RSVP for #{@rsvp.event.title} has been received")
  end

  def rsvp_nag_email
    @member = params[:member]
    @event = params[:event]
    @unit = @member.unit
    mail(to: email_address_with_name(@member.email, @member.full_display_name),
         from: unit_from_address_with_name,
         subject: "#{@unit.name}: RSVP needed!")
  end
end
