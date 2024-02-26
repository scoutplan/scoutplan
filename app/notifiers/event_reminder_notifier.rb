class EventReminderNotifier < ScoutplanNotifier
  LEAD_TIME = 12.hours.freeze

  deliver_by :email do |config|
    config.mailer = "EventReminderMailer"
    config.method = :event_reminder_notification
    config.if = ->{ recipient.unit.settings(:communication).event_reminders == "true" }
  end

  deliver_by :twilio_messaging do |config|
    config.json = :format_for_twilio
    config.credentials = :twilio_credentials
    config.ignore_failure = true
    config.if = ->{ recipient.unit.settings(:communication).event_reminders == "true" }
  end

  required_param :event
end
