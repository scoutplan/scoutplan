# frozen_string_literal: true

# controller for handling inbound SMS messages
class InboundSmsController < ApplicationController
  http_basic_authenticate_with name: ENV["SMS_BASIC_USERNAME"], password: ENV["SMS_BASIC_PASSWORD"]
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token
  layout false

  def receive
    service = SmsResponseService.new(params, request)
    service.process
    head :no_content
  end
end
