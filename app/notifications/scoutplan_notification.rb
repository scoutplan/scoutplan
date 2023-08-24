# frozen_string_literal: true

# A subclass of Noticed::Base with additional methods for sending SMS
class ScoutplanNotification < Noticed::Base
  def format_for_twilio
    res = {
      From: ENV.fetch("TWILIO_NUMBER"),
      To: recipient.phone_number,
      Body: sms_body(recipient: recipient, event: params[:event])
    }
    ap res
    res
  end

  def twilio_credentials
    {
      account_sid: ENV.fetch("TWILIO_SID"),
      auth_token: ENV.fetch("TWILIO_TOKEN"),
      phone_number: ENV.fetch("TWILIO_NUMBER")
    }
  end

  def sms_body(**assigns)
    renderer.render(
      template: "sms_notifications/#{base_name}",
      format: "text",
      assigns: assigns
    )
  end

  def base_name
    self.class.name.underscore.split("_")[0..-2].join("_")
  end

  def email?
    recipient.contactable?(via: :email) && feature_enabled?
  end

  def sms?
    recipient.contactable?(via: :sms) && feature_enabled?
  end

  # override in subclasses
  def feature_enabled?
    raise NotImplementedError
  end

  def renderer
    ApplicationController.renderer.new(
      http_host: Rails.application.config.action_mailer.default_url_options[:host],
      https: Rails.application.config.action_mailer.default_url_options[:protocol].to_s == "https"
    )
  end
end
