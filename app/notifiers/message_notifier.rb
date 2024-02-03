class MessageNotifier < ScoutplanNotifier
  deliver_by :email do |config|
    config.mailer = "MessageMailer"
    config.method = :message_notification
    config.if = :email?
  end

  deliver_by :twilio_messaging do |config|
    config.json = :format_for_twilio
    config.credentials = :twilio_credentials
    config.ignore_failure = true
    config.if = :sms?
  end

  required_param :message

  def feature_enabled?
    true
  end

  def email?
    result = super
    Rails.logger.warn("MessageNotifier#email? #{result}")
    result
  end

  def format_for_twilio
    {
      From: ENV.fetch("TWILIO_NUMBER"),
      To:   recipient.phone,
      Body: sms_body(recipient: recipient, message: params[:message])
    }
  end
end
