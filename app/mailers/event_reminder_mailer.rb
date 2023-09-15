# frozen_string_literal: true

class EventReminderMailer < ApplicationMailer
  layout "basic_mailer"

  helper ApplicationHelper
  helper MagicLinksHelper

  # called from EventReminderNotification
  def event_reminder_notification
    @member = params[:recipient]
    @event = params[:event]
    @unit = @event.unit
    @family = @member.family
    @family_rsvps = @event.rsvps.where(unit_membership_id: @family.pluck(:id)) || []
    # @family_going = @family_rsvps.select { |rsvp| rsvp.response == "accepted" }

    attachments[@event.ical_filename] = ics_attachment
    # attachments.inline["rsvp-going.png"] = File.read(Rails.root.join("app/assets/images/rsvp-going.png"))
    # attachments.inline["rsvp-not-going.png"] = File.read(Rails.root.join("app/assets/images/rsvp-not-going.png"))
    # attachments.inline["rsvp-no-response.png"] = File.read(Rails.root.join("app/assets/images/rsvp-no-response.png"))
    mail(to: to_address, from: @unit.from_address, subject: subject)
    persist_invitation
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

  def subject
    "[#{@event.unit.name}] #{@event.title} Reminder"
  end

  def to_address
    email_address_with_name(@member.email, @member.full_display_name)
  end
end
