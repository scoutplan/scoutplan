# frozen_string_literal: true

class WeeklyDigestNotification < ScoutplanNotification
  deliver_by :email, mailer: "WeeklyDigestMailer", if: :email?
  deliver_by :twilio

  before_deliver do
    @events = @unit.events.imminent
  end

  param :unit

  def feature_enabled?
    recipient.unit.settings(:communication).digest == "true"
  end
end
