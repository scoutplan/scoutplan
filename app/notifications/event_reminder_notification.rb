# frozen_string_literal: true

class EventReminderNotification < ScoutplanNotification
  LEAD_TIME = 12.hours.freeze

  deliver_by :database
  deliver_by :email, mailer: "EventReminderMailer", if: :email?
  deliver_by :twilio, if: :sms?, format: :format_for_twilio, credentials: :twilio_credentials

  param :event

  def feature_enabled?
    recipient.unit.settings(:communication).daily_reminder == "true"
  end
end
