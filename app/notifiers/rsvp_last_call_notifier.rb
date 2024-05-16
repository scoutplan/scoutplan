class RsvpLastCallNotifier < ScoutplanNotifier
  deliver_by :email do |config|
    config.mailer = "RsvpLastCallMailer"
    config.method = :rsvp_last_call_notification
    config.if = :should_send?
  end

  deliver_by :twilio_messaging do |config|
    config.json = :format_for_twilio
    config.credentials = :twilio_credentials
    config.ignore_failure = true
    config.if = :sms?
  end

  required_param :event

  def format_for_twilio(notification)
    recipient = notification.recipient
    {
      "From" => ENV.fetch("TWILIO_NUMBER"),
      "To"   => recipient.phone,
      "Body" => sms_body(recipient: recipient, event: params[:event], unit: params[:event].unit)
    }
  end

  def feature_enabled?
    true
  end

  def should_send?(notification)
    email?(notification)
  end
end
