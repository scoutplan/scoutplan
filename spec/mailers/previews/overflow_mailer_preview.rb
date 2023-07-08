# Preview all emails at http://localhost:3000/rails/mailers/overflow_mailer

require "action_mailbox"

class OverflowMailerPreview < ActionMailer::Preview
  def overflow_mail_notification
    inbound_email = ActionMailbox::InboundEmail.first
    recipient = UnitMembership.first

    OverflowMailer.with(inbound_email: inbound_email, recipient: recipient).overflow_mail_notification # rubocop:disable Style/HashSyntax
  end
end
