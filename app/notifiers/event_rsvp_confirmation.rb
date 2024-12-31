class EventRsvpConfirmation < ScoutplanNotifier
  notification_methods do
    def title
      return "Your RSVP for #{record.event.title} has been received!" if record.present?

      "Your RSVP has been received!"
    end

    def message
      return "" unless record.present?

      path = rsvp_unit_event_path(record.unit, record.event)
      "Your RSVP for #{record.event.title} has been received. <a href='#{path}'>Click here</a> if you have a change of plans."
    end
  end

  deliver_by :email do |config|
    config.mailer = "EventRsvpConfirmationMailer"
    config.method = :event_rsvp_confirmation
    config.if = :email?
  end

  deliver_by :twilio_messaging do |config|
    config.json = :format_for_twilio
    config.credentials = :twilio_credentials
    config.ignore_failure = true
    config.if = :sms?
  end

  required_param :event_rsvp

  def feature_enabled?
    true
  end

  def format_for_twilio(notification)
    recipient = notification.recipient
    params = notification.params
    {
      "From" => ENV.fetch("TWILIO_NUMBER"),
      "To"   => recipient.phone,
      "Body" => sms_body(recipient: recipient, event_rsvp: params[:event_rsvp])
    }
  end
end
