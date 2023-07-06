# The EmailEvaluator is responsible for analyzing the email to determine the appropriate mailbox
# to route to. It is used by the ApplicationMailbox.
class EmailEvaluator
  attr_reader :unit

  def initialize(inbound_email)
    @mail = inbound_email.mail
    find_unit
  end

  # returns true if the email is an auto-responder
  def auto_responder?
    @mail.header["Auto-Submitted"].present? && @mail.header["Auto-Submitted"].value == "auto-replied"
  end

  # returns true if a unit is found from the 
  def unit?
    @unit.present?
  end

  private

  def find_unit
    sender = @mail.to.first.split("@").first
    sender_parts = sender.split(".")
    @slug = sender_parts.first
    @modifiers = sender_parts.drop(1)
    @unit = Unit.find_by(slug: @slug)
  end
end
