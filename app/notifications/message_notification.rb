# frozen_string_literal: true

class MessageNotification < Noticed::Base
  deliver_by :database
  deliver_by :email, mailer: "MessageMailer", if: :email?
  deliver_by :twilio, if: :sms?, format: :format_for_twilio, credentials: :twilio_credentials, ignore_failure: true

  param :message

  def feature_enabled?
    true
  end
end
