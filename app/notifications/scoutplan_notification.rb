# frozen_string_literal: true

class ScoutplanNotification < Noticed::Base
  def format
    {
      From: ENV.fetch("TWILIO_PHONE_NUMBER"),
      To: recipient.phone_number,
      Body: sms_body(recipient: recipient, event: params[:event])
    }
  end

  def sms_body(**assigns)
    renderer.render(
      template: "sms_notifications/#{base_name}",
      format: "text",
      assigns: assigns # rubocop:disable Style/HashSyntax
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
