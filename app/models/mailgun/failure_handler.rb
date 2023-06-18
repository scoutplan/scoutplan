# frozen_string_literal: true

class Mailgun::FailureHandler
  def initialize(data)
    @data = data
  end

  def process
    reason = @data["reason"]
    ap reason
    if reason == "suppress-bounce"
      ScoutplanAdminMailer.with(
        from_address: @data["message"]["headers"]["from"],
        to_address: @data["message"]["headers"]["to"],
        message_id: @data["id"]).mail_failure_email.deliver_later
    end
  end
end