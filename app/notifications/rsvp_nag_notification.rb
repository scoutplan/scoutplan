# To deliver this notification:
#
# RsvpNagNotification.with(post: @post).deliver_later(current_user)
# RsvpNagNotification.with(post: @post).deliver(current_user)

class RsvpNagNotification < ScoutplanNotification
  deliver_by :email, mailer: "RsvpNagMailer", if: :email?
  deliver_by :twilio, if: :sms?, format: :format_for_twilio, credentials: :twilio_credentials, ignore_failure: true

  before_send :feature_enabled?

  param :event

  def format_for_twilio
    {
      From: ENV.fetch("TWILIO_NUMBER"),
      To:   recipient.phone,
      Body: sms_body(recipient: recipient)
    }
  end

  def feature_enabled?
    recipient.unit.settings(:communication).digest == "true"
  end
end
