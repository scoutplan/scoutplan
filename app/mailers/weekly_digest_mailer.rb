# frozen_string_literal: true

class WeeklyDigestMailer < ApplicationMailer
  layout "even_more_basic_mailer"

  before_action :setup

  helper ApplicationHelper

  attr_reader :unit

  def weekly_digest_notification
    Rails.logger.warn("WeeklyDigestMailer#weekly_digest_notification to: #{to_address} from: #{from_address}")
    mail(to: to_address, from: from_address, subject: subject)
  end

  private

  # rubocop:disable Metrics/AbcSize
  def setup
    @recipient = params[:recipient]
    @unit = params[:unit]
    @this_week_events   = unit.events.published.this_week
    @coming_up_events   = unit.events.published.coming_up
    @further_out_events = unit.events.published.further_out.rsvp_required
  end
  # rubocop:enable Metrics/AbcSize

  def subject
    "[#{unit.name}] Weekly Digest"
  end

  def from_address
    email_address_with_name(unit.from_address, unit.name)
  end

  def to_address
    email_address_with_name(@recipient.email, @recipient.display_name)
  end
end
