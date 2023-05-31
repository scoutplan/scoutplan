# a Mailbox for handling incoming mail
class ForwardsMailbox < ApplicationMailbox
  before_processing :ensure_unit

  def process
    ap unit
  end

  private

  def ensure_unit
    bounced! unless unit
    # TODO: send bounce email to sender
  end

  def slug_from_recipient
    mail.to.first.split("@").second.split(".").first
  end

  def unit
    @unit ||= Unit.find_by(slug: slug_from_recipient)
  end
end
