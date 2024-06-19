class WeeklyDigestNotifier < ScoutplanNotifier
  notification_methods do
    def title
      "Weekly Digest"
    end
  end

  deliver_by :email do |config|
    config.mailer = "WeeklyDigestMailer"
    config.method = :weekly_digest_notification
    config.if = :email?
  end

  deliver_by :twilio_messaging do |config|
    config.json = :format_for_twilio
    config.credentials = :twilio_credentials
    config.ignore_failure = true
    config.if = :sms?
  end

  required_param :unit

  def feature_enabled?
    true
  end

  def format_for_twilio(notification)
    recipient = notification.recipient
    params = notification.params
    {
      "From" => ENV.fetch("TWILIO_NUMBER"),
      "To"   => recipient.phone,
      "Body" => sms_body(recipient: recipient, unit: params[:unit])
    }
  end
end
