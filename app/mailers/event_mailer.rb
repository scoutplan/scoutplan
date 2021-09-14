# frozen_string_literal: true

class EventMailer < ApplicationMailer
  def token_invitation_email
    @token = params[:token]
    @event = @token.event
    @user  = @token.user
    @unit  = @event.unit
    @url   = rsvp_response_url(@token.value)
    mail(to: @user.email, from: @unit.from_email, subject: "#{@unit.name} — Event Invitation: #{@event.title}")
  end

  def bulk_publish_email
    @unit   = params[:unit]
    @user   = params[:user]
    @events = params[:events]
    @url    = unit_events_url(@unit)
    mail(to: @user.email, from: @unit.from_email, subject: "#{@unit.name} — New Events Have Been Added to the Calendar")
  end
end
