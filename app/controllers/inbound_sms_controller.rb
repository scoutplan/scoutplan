# frozen_string_literal: true

# controller for handling inbound SMS messages
class InboundSmsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token
  layout false

  def receive
    service = SmsResponseService.new(params)
    service.process
    head :no_content
  end
end
