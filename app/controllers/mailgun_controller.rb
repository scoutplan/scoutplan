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

  #
  # POST /webhooks/mailgun/receive
  #
  def receive
    data = JSON.parse(request.body.read)
    sig_data = data["signature"]
    head 500 and return unless verify(sig_data["token"], sig_data["timestamp"], sig_data["signature"])

    handler = create_handler(data["event-data"])
    head :no_content, status: 200 and return unless handler

    handler.process
    head 200
  end

  private
  
  #
  # pass in event data and get back a handler object, if one exists
  #
  def create_handler(event_data)
    event = event_data["event"]
    ap event
    case event
    when "failed"
      Mailgun::FailureHandler.new(event_data)
    else
      nil
    end
  end
  
  #
  # ensure that the request is from Mailgun
  #
  def verify(token, timestamp, signature)
    signing_key = ENV["MAILGUN_INGRESS_SIGNING_KEY"]
    digest = OpenSSL::Digest::SHA256.new
    data = [timestamp, token].join
    signature == OpenSSL::HMAC.hexdigest(digest, signing_key, data)
  end  
end
