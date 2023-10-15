# frozen_string_literal: true

class EventRsvpMailer < ApplicationMailer
  layout "basic_mailer"

  helper GrammarHelper, ApplicationHelper, MagicLinksHelper

  before_action :set_event_rsvp, :set_member, :set_unit, :set_event

  def event_rsvp_notification
    attachments[@event.ical_filename] = IcalExporter.ics_attachment(@event, @member)
    begin
      attachments["map.png"] = File.read(URI.parse(map_url).open)
    rescue TypeError
      # If the map_url is nil, then we don't have a map to attach
    end

    mail(to: to_address, from: from_address, reply_to: reply_to, subject: subject)
  end

  private

  def set_event
    @event = @rsvp.event
  end

  def set_event_rsvp
    @rsvp = params[:event_rsvp]
  end

  def set_member
    @member = @rsvp.member
  end

  def set_unit
    @unit = @rsvp.unit
  end

  def to_address
    email_address_with_name(@member.email, @member.full_display_name)
  end

  def from_address
    email_address_with_name(@unit.from_address, @unit.name)
  end

  def subject
    "[#{@unit.name}] Your RSVP for #{@event.title} has been received"
  end

  def reply_to
    @rsvp.reply_to
  end

  def map_url
    query = CGI.escape(@event.map_address.gsub(",", ""))
    params = "key=#{ENV.fetch('GOOGLE_API_KEY', nil)}&center=#{query}&markers=|#{query}&zoom=10&size=500x300"
    "https://maps.googleapis.com/maps/api/staticmap?#{params}"
  end
end
