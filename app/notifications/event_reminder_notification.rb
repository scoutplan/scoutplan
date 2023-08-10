# frozen_string_literal: true

# EventReminderNotification.with(event: @event).deliver_later(@event.attendees)
class EventReminderNotification < Noticed::Base
  deliver_by :database
  deliver_by :email, mailer: "EventReminderMailer", if: :emailable?
  deliver_by :twilio, if: :smsable?

  param :event
  param :message

  def emailable?
    recipient.emailable? && recipient.unit.settings(:communication).daily_reminder == "yes"
  end

  def smsable?
    recipient.smsable? && recipient.unit.settings(:communication).daily_reminder == "yes"
  end
end
