# frozen_string_literal: true

class MessageNotifier < ScoutplanNotifier
  deliver_by :email, mailer: "MessageMailer", method: :message_notification, if: :email?
  deliver_by :twilio_messaging, if: :sms?, format: :format_for_twilio, credentials: :twilio_credentials,
             ignore_failure: true, debug: true

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
