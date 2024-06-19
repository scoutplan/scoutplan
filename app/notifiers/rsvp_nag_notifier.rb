class RsvpNagNotifier < ScoutplanNotifier
  notification_methods do
    def title
      "Your RSVP is requested for an upcoming event"
    end
  end

  deliver_by :email do |config|
    config.mailer = "RsvpNagMailer"
    config.method = :rsvp_nag_notification
    config.if = :email?
  end

  deliver_by :twilio_messaging do |config|
    config.json = :format_for_twilio
    config.credentials = :twilio_credentials
    config.ignore_failure = true
    config.if = :sms?
  end

  def feature_enabled?
    unit.settings(:communication).rsvp_nag == "true"
  end
end
