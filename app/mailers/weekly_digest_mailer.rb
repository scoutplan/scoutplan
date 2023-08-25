# frozen_string_literal: true

class WeeklyDigestMailer < ApplicationMailer
  layout "basic_mailer"

  helper ApplicationHelper

  def weekly_digest_notification
    @recipient = params[:recipient]
    @unit = params[:unit]

    mail(to: @recipient.email, from: @unit.from_address, subject: subject)
  end

  def subject
    "[#{@event.unit.name}] Weekly Digest"
  end
end
