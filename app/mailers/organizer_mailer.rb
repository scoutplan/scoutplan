# frozen_string_literal: true

# mailer for event organizer messages
class OrganizerMailer < ApplicationMailer
  helper MagicLinksHelper

  def daily_digest_email
    @event = params[:event]
    @unit = @event.unit
    @organizer = params[:organizer]
    @new_rsvps = params[:new_rsvps]
    mail(to: @organizer.email,
         from: @unit.settings(:communication).from_email,
         subject: "#{@event.unit.name} #{@event.title} Update")
  end
end
