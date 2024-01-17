class RsvpNagNotification < ScoutplanNotification
  deliver_by :email, mailer: "RsvpNagMailer", if: :email?
  deliver_by :twilio, if: :sms?, format: :format_for_twilio, credentials: :twilio_credentials, ignore_failure: true

  param :event

  def email?
    puts "email?"
    super
  end

  def format_for_twilio
    {
      From: ENV.fetch("TWILIO_NUMBER"),
      To:   recipient.phone,
      Body: sms_body(recipient: recipient)
    }
  end

  def feature_enabled?
    recipient.unit.settings(:communication).digest == "true"
  end
end
