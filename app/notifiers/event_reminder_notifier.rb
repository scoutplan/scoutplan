class EventReminderNotifier < ScoutplanNotifier
  LEAD_TIME = 12.hours.freeze

  deliver_by :email, mailer: "EventReminderMailer", method: :event_reminder_notification, if: :email?
  deliver_by :twilio_messaging, if: :sms?, format: :format_for_twilio, credentials: :twilio_credentials, ignore_failure: true

  required_param :event

  def feature_enabled?
    recipient.unit.settings(:communication).event_reminders == "true"
  end
end
