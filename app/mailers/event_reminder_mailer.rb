# frozen_string_literal: true

class EventReminderMailer < ApplicationMailer
  layout "basic_mailer"

  helper ApplicationHelper

  # called from EventReminderNotification
  def event_reminder_notification
    @recipient = params[:recipient]
    @event = params[:event]
    @unit = @event.unit
    @family_rsvps = @event.rsvps.where(unit_membership_id: @recipient.family.pluck(:id))
    @family_going = @family_rsvps.select { |rsvp| rsvp.response == "accepted" }

    return if @event.requires_rsvp && @family_going.empty?

    mail(to: @recipient.email, from: @unit.from_address, subject: subject)
  end

  def subject
    "[#{@event.unit.name}] #{@event.title} Reminder"
  end
end
