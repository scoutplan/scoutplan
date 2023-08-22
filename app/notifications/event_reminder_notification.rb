# frozen_string_literal: true

class EventReminderNotification < ScoutplanNotification
  LEAD_TIME = 12.hours.freeze

  deliver_by :database
  deliver_by :email, mailer: "EventReminderMailer", if: :email?
<<<<<<< HEAD
  deliver_by :twilio, if: :sms?, format: :format_for_twilio, credentials: :twilio_credentials, ignore_failure: true
=======
  deliver_by :twilio, if: :sms?, format: :format_for_twilio, credentials: :twilio_credentials
>>>>>>> 68940b7f (Initial commit)

  param :event

  def feature_enabled?
    recipient.unit.settings(:communication).daily_reminder == "true" &&
      (Flipper.enabled?(:sms_event_reminders, recipient) || ENV["RAILS_ENV"] == "test")
  end
end
