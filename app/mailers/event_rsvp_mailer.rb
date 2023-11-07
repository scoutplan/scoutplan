# frozen_string_literal: true

class EventRsvpMailer < ApplicationMailer
  MAP_ATTACHMENT_NAME = "map.png"

  layout "basic_mailer"

  helper GrammarHelper, ApplicationHelper, MagicLinksHelper, EventsHelper

  before_action :set_event_rsvp, :set_member, :set_recipient, :set_unit, :set_event

  def event_rsvp_notification
    attach_files
    mail(to: to_address, from: from_address, reply_to: reply_to, subject: subject, template_name: template_name)
  end

  private

  def attach_files
    attachments[@event.ical_filename] = IcalExporter.ics_attachment(@event, @member)
    attachments[MAP_ATTACHMENT_NAME] = @event.static_map.blob.download if @event.static_map.attached?
  end

  def set_event
    @event = @rsvp.event
  end

  def set_event_rsvp
    @rsvp = params[:event_rsvp]
  end

  def set_recipient
    @recipient = params[:recipient]
  end

  def set_member
    @member = @rsvp.member
  end

  def set_unit
    @unit = @rsvp.unit
  end

  def template_name
    @member == @recipient ? "event_rsvp_notification" : "event_rsvp_notification_for_other"
  end

  def to_address
    email_address_with_name(@recipient.email, @recipient.full_display_name)
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
