# frozen_string_literal: true

# A Notifier class for reminding Members to RSVP to what's next
# on the calendar that they haven't yet responded to
class RsvpNagNotifier < ApplicationNotifier
  def perform
    return unless member.contactable?
    return unless (event = find_event)

    send_email { |recipient| EventMailer.with(member: recipient, event: event).nag_email.deliver_later }
    send_text  { |recipient| RsvpNagTexter.new(recipient, event).send_message }
  end

  private

  # we're looking for the next event within the next 30 days where the member's family hasn't
  # completely responded
  def find_event
    rsvp_service = RsvpService.new(member)
    candidate_events = unit.events.published.requires_rsvp.where("starts_at BETWEEN ? AND ?", DateTime.now, 30.days.from_now)
    candidate_events.each do |event|
      rsvp_service.event = event
      return event unless rsvp_service.family_fully_responded?
    end
  end

  def unit
    @member.unit
  end
end
