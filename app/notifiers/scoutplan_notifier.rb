# frozen_string_literal: true

class ScoutplanNotifier < Noticed::Event
  def format_for_twilio(notification)
    recipient = notification.recipient
    params = notification.params
    {
      "From" => ENV.fetch("TWILIO_NUMBER"),
      "To"   => recipient.phone,
      "Body" => sms_body(recipient: recipient, event: params[:event], params: params)
    }
  end

  def sms_body(**assigns)
    Time.use_zone(time_zone) do
      template = "sms_notifications/#{self.class.name.underscore}"
      renderer.render(template: template, format: "text", assigns: assigns)
    end
  end

  def time_zone
    unit&.time_zone || Rails.application.config.default_time_zone
  end

  def twilio_credentials(*)
    {
      account_sid:  ENV.fetch("TWILIO_SID"),
      auth_token:   ENV.fetch("TWILIO_TOKEN"),
      phone_number: ENV.fetch("TWILIO_NUMBER")
    }
  end

  def unit; end

  def base_name
    self.class.name.underscore.split("_")[0..-2].join("_")
  end

  def email?(notification = nil)
    recipient = notification&.recipient
    recipient.contactable_via?(:email) && feature_enabled?
  end

  def sms?(notification = nil)
    recipient = notification&.recipient
    recipient.contactable_via?(:sms) && feature_enabled?
  end

  # override in subclasses as needed
  def feature_enabled?
    true
  end

  def renderer
    ApplicationController.renderer.new(
      http_host: Rails.application.default_url_options[:host],
      https:     Rails.application.default_url_options[:protocol].to_s == "https"
    )
  end
end
