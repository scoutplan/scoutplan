# frozen_string_literal: true

# This notification is sent to all attendees of an event 12 hours before the event starts.
# Invoke like so:
#
# EventReminderNotification.with(event: @event).deliver_later(@event.attendees)
class EventReminderNotification < ScoutplanNotification
  LEAD_TIME = 12.hours.freeze

  deliver_by :database
  deliver_by :email, mailer: "EventReminderMailer", if: :email?
  deliver_by :twilio, if: :sms?

  param :event

  def feature_enabled?
    recipient.unit.settings(:communication).daily_reminder == "true"
  end
end
