# frozen_string_literal: true

# The Mailer class for sending email relating to specific events
#
class EventMailer < ScoutplanMailer
  def cancellation_email
    @event  = params[:event]
    @member = params[:member]
    @note   = params[:note]
    mail(
      to: @member.email,
      from: @unit.settings(:communication).from_email,
      subject: "#{@unit.name} #{@event.title} Cancelled"
    )
  end

  def token_invitation_email
    @token = params[:token]
    @event = @token.event
    @user  = @token.user
    @url   = rsvp_response_url(@token.value)
    mail(
      to: @user.email,
      from: @unit.settings(:communication).from_email,
      subject: "#{@unit.name} Event Invitation: #{@event.title}"
    )
  end

  def bulk_publish_email
    @user   = params[:user]
    @events = Event.find(params[:event_ids])
    @url    = unit_events_url(@unit)
    mail(to: @user.email,
         from: @unit.settings(:communication).from_email,
         subject: "#{@unit.name}: New Events Have Been Added to the Calendar")
  end

  def rsvp_confirmation_email
    @rsvp = params[:rsvp]
    user = @rsvp.user
    mail(to: email_address_with_name(user.email, user.full_display_name),
         from: email_address_with_name(@rsvp.unit.settings(:communication).from_email, @rsvp.unit.name),
         subject: "#{@rsvp.unit.name}: Your RSVP for #{@rsvp.event.title} has been received")
  end

  def rsvp_nag_email
    @member = params[:member]
    @event = params[:event]
    @unit = @member.unit
    mail(to: email_address_with_name(@member.email, @member.full_display_name),
         from: email_address_with_name(@unit.settings(:communication).from_email, @unit.name),
         subject: "#{@rsvp.unit.name}: RSVP needed!")
  end
end
