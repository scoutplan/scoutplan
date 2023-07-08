# frozen_string_literal: true

#
# A fallback mailer for handling incoming mail not handled elsewhere
#
class OverflowMailer < ApplicationMailer
  layout "basic_mailer"

  def overflow_mail_notification
    inbound_email = params[:inbound_email]
    recipient = params[:recipient]

    @unit = params[:unit]
    @email = inbound_email.mail
    subject = "[Delivered via Scoutplan] #{@email.subject}"

    Rails.logger.warn "Sending overflow mail to #{recipient.email}"

    mail(to: recipient.email, from: @email.from.first, subject: subject)
  end
end
