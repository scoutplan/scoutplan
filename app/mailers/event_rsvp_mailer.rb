# frozen_string_literal: true

class EventRsvpMailer < ApplicationMailer
  layout "basic_mailer"

  helper GrammarHelper, ApplicationHelper, MagicLinksHelper

  before_action :set_event_rsvp, :set_member, :set_unit, :set_event

  def event_rsvp_notification
    attachments[@event.ical_filename] = IcalExporter.ics_attachment(@event, @member)
    attachments["map.png"] = @event.static_map.blob.download if @event.static_map.attached?
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
end
