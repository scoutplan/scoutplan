class EventRsvpNotification < ScoutplanNotification
  deliver_by :database
  deliver_by :email, debug: true, mailer: "EventRsvpMailer", if: :email?
  deliver_by :twilio, if: :sms?, format: :format_for_twilio, credentials: :twilio_credentials,
             ignore_failure: true, debug: true

  param :event_rsvp

  def feature_enabled?
    true
  end

  def format_for_twilio
    {
      From: ENV.fetch("TWILIO_NUMBER"),
      To:   recipient.phone,
      Body: sms_body(recipient: recipient, message: params[:event_rsvp])
    }
  end
end
