# frozen_string_literal: true

# Rails Mailer for sending communications to UnitMemberships (members)
class MemberMailer < ScoutplanMailer
  before_action :set_addresses
  before_action :time_zone
  helper MagicLinksHelper

  def family_rsvp_confirmation_email
    @event = Event.find(params[:event_id])
    @service = RsvpService.new(@member, @event)
    mail(to: @to_address,
         from: @from_address,
         subject: "#{@unit.name} — Your RSVP has been received")
  end

  def invitation_email
    mail(to: @to_address,
         from: @from_address,
         subject: "Welcome to #{@unit.name}")
  end

  def digest_email
    Rails.logger.info "Emailing digest to #{@to_address}"
    @this_week_events = params[:this_week_events]
    @upcoming_events = params[:upcoming_events]
    mail(
      to: @to_address,
      from: @from_address,
      subject: "#{@unit.name} Digest"
    )
  end

  def event_organizer_daily_digest_email
    @event = params[:event]
    @member = params[:member]
    @rsvps = params[:rsvps]
    @last_ran_at = params[:last_ran_at] || @event.created_at

    mail(to: @member.email,
         from: @from_address,
         subject: "#{@event.unit.name} #{@event.title} RSVPs")
  end

  def message_email
    @message = Message.find(params[:message_id])
    subject = params[:preview] ? "[PREVIEW] " : ""
    subject += "#{@unit.name} — #{@message.title}"

    @message.attachments.each do |attachment|
      attachments[attachment.filename.to_s] = attachment.download
    end

    mail(
      to: @to_address,
      from: unit_from_address_with_name(@message.author.short_display_name),
      subject: subject
    )
  end

  def daily_reminder_email
    Rails.logger.info "Emailing Daily Reminder to #{@member.flipper_id}..."
    @events = @unit.events.published.imminent
    @rsvp_closes_three_days = @unit.events.published.where(
      "rsvp_closes_at BETWEEN ? AND ?",
      3.days.from_now.beginning_of_day,
      3.days.from_now.end_of_day
    )

    mail(
      to: @to_address,
      from: @from_address,
      subject: daily_reminder_subject
    )
  end

  def rsvp_last_call_email
    @events = Event.find(params[:event_ids])
    @unit = @events.first.unit
    mail(
      to: @to_address,
      from: @from_address,
      subject: annotated_subject(t("mailers.member_mailer.rsvp_nag.subject"))
    )
  end

  def rsvp_nag_email
    @event = Event.find(params[:event_id])
    @unit = @event.unit
    mail(
      to: @to_address,
      from: @from_address,
      subject: annotated_subject(t("mailers.member_mailer.rsvp_nag.subject"))
    )
  end

  def test_email
    mail(
      to: @to_address,
      from: @from_address,
      subject: "Test Message from #{@unit.name}"
    )
  end

  private

  def set_addresses
    @to_address = email_address_with_name(@member.user.email, @member.user.full_display_name)
    @from_address = unit_from_address_with_name
  end

  def unit_email_address
    @unit.slug + "@" + ENV["EMAIL_DOMAIN"]
  end

  def daily_reminder_subject
    Time.zone = @unit.settings(:locale).time_zone

    res = "#{@unit.name} — Event Reminder"
    res += ": #{@events.first.title}" if @events.count == 1
    res
  end

  def find_member
    @member = params[:member]
  end

  def time_zone
    Time.zone = @unit.settings(:locale).time_zone
  end
end
