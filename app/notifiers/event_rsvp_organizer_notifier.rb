class EventRsvpOrganizerNotifier < ScoutplanNotifier
  deliver_by :email, mailer: "EventRsvpOrganizerMailer", method: :event_rsvp_organizer_notification, if: :email?
  deliver_by :twilio_messaging, if: :sms?, format: :format_for_twilio, credentials: :twilio_credentials, ignore_failure: true

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
