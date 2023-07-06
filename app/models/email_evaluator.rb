# The EmailEvaluator is responsible for analyzing the email to determine the appropriate mailbox
# to route to. It is used by the ApplicationMailbox.
class EmailEvaluator
  AUTO_RESPONDER_HEADER = "Auto-Submitted"
  AUTO_RESPONDER_VALUES = ["auto-replied", "auto-generated"]
  attr_reader :unit

  def initialize(inbound_email)
    @mail = inbound_email.mail
    evaluate
  end

  # returns true if the email is an auto-responder
  def auto_responder?
    return false unless (val = @mail.header["Auto-Submitted"].present?)

    AUTO_RESPONDER_VALUES.include?(val.value)
  end

  # returns true if a unit is found from the email address
  def unit?
    @unit.present?
  end

  private

  def evaluate
    sender = @mail.to.first.split("@").first
    sender_parts = sender.split(".")
    @slug = sender_parts.first
    @modifiers = sender_parts.drop(1)
    @unit = Unit.find_by(slug: @slug)
  end
end
