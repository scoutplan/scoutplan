class EventRsvpOrganizerNotifier < ScoutplanNotifier
  deliver_by :email do |config|
    config.mailer = "EventRsvpOrganizerMailer"
    config.method = :event_rsvp_organizer_notification
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
    true
  end

  def format_for_twilio
    {
      From: ENV.fetch("TWILIO_NUMBER"),
      To:   recipient.phone,
      Body: sms_body(recipient: recipient, event: params[:event])
    }
  end
end
