class RsvpNagNotifier < ScoutplanNotifier
  notification_methods do
    def title
      "Your RSVP is requested for an upcoming event"
    end
  end

  deliver_by :email do |config|
    config.mailer = "RsvpNagMailer"
    config.method = :rsvp_nag_notification
    config.if = :email?
  end

  deliver_by :twilio_messaging do |config|
    config.json = :format_for_twilio
    config.credentials = :twilio_credentials
    config.ignore_failure = true
    config.if = :sms?
  end

  # Guarded: an event whose unit has been deleted must skip quietly rather than raise inside the
  # delivery job, where the failure is invisible until someone reads solid_queue_failed_executions.
  def feature_enabled?
    return false if unit.blank?

    unit.settings(:communication).rsvp_nag == "true"
  end
end
