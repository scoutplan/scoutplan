# frozen_string_literal: true

require "openssl"

#
# This controller implements endpoints for Mailgun webhooks, as described at
# https://documentation.mailgun.com/en/latest/user_manual.html#webhooks-1
# test with https://scoutplan.ngrok.io/webhooks/mailgun/receive
# see /spec/support for sample webhook payloads
#
class MailgunController < ApplicationController
  # we validate the request through other means, so disable CSFR protection
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  # POST /webhooks/mailgun/receive
  # configure Mailgun to post exceptions to this URL
  def receive
    data = JSON.parse(request.body.read)
    sig_data = data["signature"]
    head 500 and return unless authenticate(sig_data["token"], sig_data["timestamp"], sig_data["signature"])

    handler = create_handler(data["event-data"])
    handler.process
    head :no_content, status: 200
  end

  private

  def create_handler(event_data)
    event = event_data["event"]
    case event
    when "failed"
      Mailgun::FailureHandler.new(event_data)
    else
      Mailgun::NullHandler.new(event_data)
    end
  end

  def authenticate(token, timestamp, signature)
    signing_key = ENV.fetch("MAILGUN_INGRESS_SIGNING_KEY")
    digest = OpenSSL::Digest.new("SHA256")
    data = [timestamp, token].join
    signature == OpenSSL::HMAC.hexdigest(digest, signing_key, data)
  end
end
