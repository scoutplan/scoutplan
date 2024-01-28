class RsvpNagNotifier < ScoutplanNotifier
  deliver_by :email, mailer: "RsvpNagMailer", method: :rsvp_nag_notification, if: :email?
  deliver_by :twilio_messaging, if: :sms?, format: :format_for_twilio, credentials: :twilio_credentials, ignore_failure: true

  required_param :event

  def format_for_twilio
    {
      From: ENV.fetch("TWILIO_NUMBER"),
      To:   recipient.phone,
      Body: sms_body(recipient: recipient, event: params[:event], unit: params[:event].unit)
    }
  end

  def feature_enabled?
    recipient.unit.settings(:communication).digest == "true" && Flipper.enabled?(:rsvp_nag, recipient)
  end
end
