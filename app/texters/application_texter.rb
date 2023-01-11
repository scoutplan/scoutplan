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

  def renderer
    ApplicationController.renderer.new(
      http_host: ENV["SCOUTPLAN_HOST"],
      https: ENV["SCOUTPLAN_PROTOCOL"] == "https"
    )
  end

  # returns true if successful, false if not
  def send_message
    send_intro_message

    raise ArgumentError, "'to' argument missing" unless to.present?
    return unless body

    Rails.logger.warn { "Sending SMS to #{to}: #{body}" }
    @client.messages.create(from: @from, to: to, body: body)
    true
  rescue Twilio::REST::RestError => e
    Rails.logger.error { e.message }
    false
  end

  # override in subclasses
  def body; end
  def to; end

  private

  def send_intro_message
    user = User.find_by(phone: to)
    return if user.settings(:communication).intro_sms_sent

    user.settings(:communication).intro_sms_sent = true
    user.save!
    @client.messages.create(from: @from, to: to, body: intro_message(user))
  end

  def intro_message(user)
    renderer.render(
      template: "user_texter/intro",
      layout: false,
      locals: { user: user }
    )
  end
end
