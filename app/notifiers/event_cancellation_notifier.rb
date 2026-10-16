# Tells members that an event was cancelled. It carries the event's title and start time rather
# than the event itself because the organizer may have deleted the event outright.
class EventCancellationNotifier < ScoutplanNotifier
  notification_methods do
    def title
      "Cancelled: #{params[:title]}"
    end
  end

  deliver_by :email do |config|
    config.mailer = "EventMailer"
    config.method = :cancellation_email
    config.if = :email?
  end

  deliver_by :twilio_messaging do |config|
    config.json = :format_for_twilio
    config.credentials = :twilio_credentials
    config.ignore_failure = true
    config.if = :sms?
  end

  required_param :unit, :title, :starts_at

  def format_for_twilio(notification)
    recipient = notification.recipient
    params = notification.params
    {
      "From" => ENV.fetch("TWILIO_NUMBER"),
      "To"   => recipient.phone,
      "Body" => sms_body(recipient: recipient, title: params[:title], starts_at: params[:starts_at],
                         note: params[:note])
    }
  end
end
