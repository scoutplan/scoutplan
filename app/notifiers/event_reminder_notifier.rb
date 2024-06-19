class EventReminderNotifier < ScoutplanNotifier
  LEAD_TIME = 12.hours.freeze

  notification_methods do
    def title
      "Reminder: #{record&.title}"
    end
  end

  deliver_by :email do |config|
    config.mailer = "EventReminderMailer"
    config.method = :event_reminder_notification
    config.if = :email?
  end

  deliver_by :twilio_messaging do |config|
    config.json = :format_for_twilio
    config.credentials = :twilio_credentials
    config.ignore_failure = true
    config.if = :sms?
  end

  required_param :event

  def feature_enabled?
    params[:event].unit.settings(:communication).event_reminders == "true"
  end
end
