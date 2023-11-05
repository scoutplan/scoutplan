# frozen_string_literal: true

class MessageMailer < ApplicationMailer
  layout "basic_mailer"

  before_action :set_message
  before_action :attach_files

  def message_notification
    # @message = params[:message]
    mail(to: to_address, from: from_address, reply_to: @message.email, subject: subject)
  end

  private

  def attach_files
    @message.attachments.each do |attachment|
      attachments[attachment.filename.to_s] = attachment.download
    end
  end

  def from_address
    email_address_with_name(
      @unit.from_address,
      "#{@message.author.full_display_name} at #{@unit.name}"
    )
  end

  def set_message
    @recipient = params[:recipient]
    @message = params[:message]
    @unit = @message.unit
  end

  def subject
    "[#{@unit.name}] #{@message.title}"
  end

  def to_address
    email_address_with_name(@recipient.email, @recipient.full_display_name)
  end
end
