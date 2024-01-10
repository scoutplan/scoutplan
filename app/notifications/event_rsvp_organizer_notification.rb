class EventRsvpOrganizerNotification < ScoutplanNotification
  deliver_by :database
  deliver_by :email, mailer: "EventRsvpOrganizerMailer", if: :email?
  deliver_by :twilio, if: :sms?, format: :format_for_twilio, credentials: :twilio_credentials, ignore_failure: true

  param :event

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
