# frozen_string_literal: true

class EventReminderMailer < ApplicationMailer
  layout "basic_mailer"

  helper ApplicationHelper
  helper MagicLinksHelper

  before_action :setup

  def event_reminder_notification
    attachments[@event.ical_filename] = ics_attachment
    mail(to: to_address, from: from_address, subject: subject)
  end

  private

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

  def setup
    @event = params[:event]
    @member = params[:recipient]
    @unit = @event.unit
    @family = @member.family
    @family_rsvps = @event.rsvps.where(unit_membership_id: @family.pluck(:id)) || []
  end

  ### mail methods
  def from_address
    email_address_with_name(@unit.from_address, @unit.name)
  end

  def subject
    "[#{@event.unit.name}] #{@event.title} Reminder"
  end

  def to_address
    email_address_with_name(@member.email, @member.full_display_name)
  end
end
