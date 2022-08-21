# frozen_string_literal: true

# A Notifier class for reminding Members to RSVP to what's next
# on the calendar that they haven't yet responded to
class RsvpNagNotifier < ApplicationNotifier
  attr_accessor :member

  def initialize(member)
    @member = member
    super()
  end

  def perform
    return if (!Flipper.enabled? :rsvp_nag, member) && (ENV["RAILS_ENV"] == "production")
    return unless member.contactable?
    return unless (event = find_event)

    send_email { |recipient| MemberMailer.with(member: recipient, event: event).rsvp_nag_email.deliver_later }
    send_text  { |recipient| RsvpNagTexter.new(recipient, event).send_message }
  end

  private

  # we're looking for the next event within the next 30 days where the member's family hasn't
  # completely responded
  def find_event
    rsvp_service = RsvpService.new(member)
    candidate_events = unit.events.published.rsvp_required.where("starts_at BETWEEN ? AND ?", DateTime.now, 30.days.from_now)
    candidate_events.each do |event|
      rsvp_service.event = event
      return event unless rsvp_service.family_fully_responded?
    end
  end

  def unit
    @member.unit
  end
end
