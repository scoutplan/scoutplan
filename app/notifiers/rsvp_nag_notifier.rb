class RsvpNagNotifier < ScoutplanNotifier
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

  required_param :event

  def format_for_twilio(notification)
    recipient = notification.recipient
    {
      "From" => ENV.fetch("TWILIO_NUMBER"),
      "To" => recipient.phone,
      "Body" => sms_body(recipient: recipient, event: params[:event], unit: params[:event].unit)
    }
  end

  def unit_enabled_feature?(unit)
    unit.settings(:communication).rsvp_nag == "true"
  end

  def twilio_credentials(*)
    {
      account_sid:  ENV.fetch("TWILIO_SID"),
      auth_token:   ENV.fetch("TWILIO_TOKEN"),
      phone_number: ENV.fetch("TWILIO_NUMBER")
    }
  end

  def sms?(notification)
    recipient = notification.recipient
    recipient.contactable?(via: :sms) && unit_enabled_feature?(recipient.unit)
  end

  def email?(notification)
    recipient = notification.recipient
    recipient.contactable?(via: :email) && unit_enabled_feature?(recipient.unit)
  end
end
