# frozen_string_literal: true

class WeeklyDigestMailer < ApplicationMailer
  helper MagicLinksHelper
  layout "basic_mailer"

  before_action :setup

  helper ApplicationHelper

  def weekly_digest_notification
    # attachments.inline["location_dot"] = {
    #   data:      File.read(Rails.root.join("app/assets/images/location_dot.png")),
    #   mime_type: "image/png",
    #   encoding:  "base64"
    # }
    attachments.inline["location_dot"] = File.read(Rails.root.join("app/assets/images/location_dot.png"))
    Rails.logger.warn("WeeklyDigestMailer#weekly_digest_notification to: #{to_address} from: #{from_address}")
    mail(to: to_address, from: from_address, subject: subject)
  end

  private

  def setup
    @recipient = params[:recipient]
    @unit = params[:unit]
    @this_week_events = @unit.events.published.this_week
    @coming_up_events = @unit.events.published.coming_up
  end

  def subject
    "[#{@unit.name}] Weekly Digest"
  end

  def from_address
    email_address_with_name(@unit.from_address, @unit.name)
  end

  def to_address
    email_address_with_name(@recipient.email, @recipient.display_name)
  end
end
