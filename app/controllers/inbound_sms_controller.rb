# frozen_string_literal: true

# controller for handling inbound SMS messages
class InboundSmsController < ApplicationController
  before_action :authenticate_sms_webhook
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token
  layout false

  def receive
    service = SmsResponseService.new(params, request)
    service.process
    head :no_content
  end

  private

  # Credentials are read per request rather than at class-definition time. Production eager-loads
  # every controller -- including during assets:precompile in the Docker build, where these vars
  # are not set -- and Rails now raises ArgumentError if http_basic_authenticate_with is handed a
  # nil name. Reading them here also means a restart picks up rotated values.
  def authenticate_sms_webhook
    expected_name     = ENV["SMS_BASIC_USERNAME"]
    expected_password = ENV["SMS_BASIC_PASSWORD"]

    # Fail closed: unconfigured credentials reject the request rather than accepting blanks.
    return head(:unauthorized) if expected_name.blank? || expected_password.blank?

    authenticate_or_request_with_http_basic("Application") do |name, password|
      ActiveSupport::SecurityUtils.secure_compare(name.to_s, expected_name) &
        ActiveSupport::SecurityUtils.secure_compare(password.to_s, expected_password)
    end
  end
end
