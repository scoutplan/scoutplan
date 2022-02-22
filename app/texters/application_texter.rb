# frozen_string_literal: true

# base Texter class...do not instantiate directly
class ApplicationTexter
  def initialize(*_args)
    raise "Cannot directly instantiate an ApplicationTexter" if instance_of? ApplicationTexter

    super()
    @sid   = Rails.application.credentials.twilio[:account_sid]
    @token = Rails.application.credentials.twilio[:auth_token]
    @from = ENV["TWILIO_NUMBER"]
    @client = Twilio::REST::Client.new(@sid, @token)
  end

  def send_message
    raise ArgumentError, "'to' or 'body' arguments missing" unless to && body

    Rails.logger.warn { "Sending SMS to #{to}: #{body}" }
    @client.messages.create(from: @from, to: to, body: body)
  rescue Twilio::REST::RestError => e
    Rails.logger.error { e.message }
  end

  # override in subclasses
  def body; end
  def to; end
end
