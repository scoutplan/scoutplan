# frozen_string_literal: true

class MessageNotification < ScoutplanNotification
  deliver_by :database
  deliver_by :email, mailer: "MessageMailer", if: :email?
  deliver_by :twilio, if: :sms?, format: :format_for_twilio, credentials: :twilio_credentials,
             ignore_failure: true, debug: true

  param :message

  def feature_enabled?
    true
  end

  def email?
    result = super
    Rails.logger.warn("MessageNotification#email? #{result}")
    result
  end

  def format_for_twilio
    {
      From: ENV.fetch("TWILIO_NUMBER"),
      To:   recipient.phone_number,
      Body: sms_body(recipient: recipient, message: params[:message])
    }
  end
end
