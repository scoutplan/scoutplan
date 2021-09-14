# frozen_string_literal: true

class EventMailer < ApplicationMailer
  def token_invitation_email
    @token = params[:token]
    @event = @token.event
    @user  = @token.user
    @unit  = @event.unit
    @url   = rsvp_response_url(@token.value)
    mail(to: @user.email, from: @unit.from_email, subject: "#{@unit.name} event invitation: #{@event.title}")
  end

  def bulk_publish_email
  end
end
