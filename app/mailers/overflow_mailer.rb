# frozen_string_literal: true

#
# A fallback mailer for handling incoming mail not handled elsewhere
#
class OverflowMailer < ApplicationMailer
  layout "basic_mailer"

  def overflow_mail_notification
    inbound_email = params[:inbound_email]
    recipient = params[:recipient]
    @mail = inbound_email.mail

    Rails.logger.info "Sending overflow mail to #{recipient.email}"

    # https://stackoverflow.com/questions/64140333/is-it-possible-to-forward-the-mail-object-in-action-mailer
    @mail.to = recipient.email
    @mail.from = @mail.from.first
    @mail.subject = "[Forwarded from Scoutplan] #{@mail.subject}"
    ActionMailer::Base.wrap_delivery_behavior(@mail)
    @mail.deliver
  end
end
