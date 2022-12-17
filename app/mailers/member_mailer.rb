# frozen_string_literal: true

# mailer for sending Member communications
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
    @this_week_events = @unit.events.published.this_week
    @upcoming_events = @unit.events.published.coming_up
    @news_items = @unit.messages.where("pin_until > ?", Time.now).order("created_at ASC").select(&:active?)
    mail(
      to: @to_address,
      from: @from_address,
      subject: "#{@unit.name} Digest"
    )
  end

  helper MagicLinksHelper

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
