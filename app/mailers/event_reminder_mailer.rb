# frozen_string_literal: true

class EventReminderMailer < ApplicationMailer
  layout "basic_mailer"

  helper ApplicationHelper

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
      content:             @event.to_ical(@recipient)
    }
  end

  def setup
    @recipient = params[:recipient]
    @event = params[:event]
    @unit = @event.unit
    @family = @recipient.family
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
    email_address_with_name(@recipient.email, @recipient.full_display_name)
  end
end
