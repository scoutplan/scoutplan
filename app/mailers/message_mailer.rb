# frozen_string_literal: true

class MessageMailer < ApplicationMailer
  layout "basic_mailer"

  def message_notification
    @recipient = params[:recipient]
    @message = params[:message]
    @unit = @message.unit

    mail(to: to_address, from: from_address, reply_to: @message.email, subject: subject)
  end

  private

  def from_address
    email_address_with_name(
      @unit.from_address,
      "#{@message.author.full_display_name} at #{@unit.name}"
    )
  end

  def subject
    "[#{@unit.name}] #{@message.title}"
  end

  def to_address
    email_address_with_name(@recipient.email, @recipient.full_display_name)
  end
end
