class EventRsvpConfirmation < ScoutplanNotifier
  deliver_by :email do |config|
    config.mailer = "EventRsvpConfirmationMailer"
    config.method = :event_rsvp_confirmation
    config.if = ->{ :email? }
  end

  deliver_by :twilio_messaging, if: :sms?, format: :format_for_twilio, credentials: :twilio_credentials,
             ignore_failure: false, debug: true

  required_param :event_rsvp

  def feature_enabled?
    true
  end

  def format_for_twilio
    {
      From: ENV.fetch("TWILIO_NUMBER"),
      To:   recipient.phone,
      Body: sms_body(recipient: recipient, event_rsvp: params[:event_rsvp])
    }
  end
end
