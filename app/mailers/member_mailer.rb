# frozen_string_literal: true

# mailer for sending Member communications

require "icalendar"
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
    @news_items = @unit.messages.where("pin_until > ?", Time.now).order("created_at ASC").select(&:active?)
    mail(
      to: @to_address,
      from: @from_address,
      subject: "#{@unit.name} Digest"
    )
  end

  # Sends an email that includes an event.ics attachment, so that the member's
  # mail client will treat it like a calendar invitation
  def event_invitation_email
    @event = @unit.events.find(params[:event_id])

    # Generate the ical attachment


    cal = Icalendar::Calendar.new
    exporter = IcalExporter.new(@member)
    exporter.event = @event
    cal.add_event(exporter.to_ical)

    attachments["event.ics"] = {
      mime_type: 'multipart/mixed', ## important because we are sending html and text files for the body in addition to the actual attachment
      content_type: 'text/calendar; method=REQUEST; charset=UTF-8; component=VEVENT',
      content_disposition: 'attachment; filename=event.ics',
      content: cal.to_ical
    }

    mail(to: @member.email,
         from: @unit.settings(:communication).from_email,
         subject: "#{@unit.name} is inviting you to #{@event.title}")
  end

  def event_organizer_daily_digest_email
    @event = params[:event]
    @member = params[:member]
    @rsvps = params[:rsvps]
    @last_ran_at = params[:last_ran_at] || @event.created_at

    mail(to: @member.email,
         from: @unit.settings(:communication).from_email,
         subject: "#{@event.unit.name} #{@event.title} RSVPs")
  end

  def message_email
    @message = Message.find(params[:message_id])
    subject = params[:preview] ? "[PREVIEW] " : ""
    subject += "#{@unit.name} — #{@message.title}"
    mail(
      to: @to_address,
      from: @from_address,
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
    @from_address = email_address_with_name(@unit.settings(:communication).from_email, @unit.name)
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
