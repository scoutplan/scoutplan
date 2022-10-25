# frozen_string_literal: true

# A Notifier class for reminding Members to RSVP to what's next
# on the calendar that they haven't yet responded to
class RsvpNagNotifier < ApplicationNotifier
  attr_accessor :member

  def initialize(member)
    @member = member
    super()
  end

  # rubocop:disable Metrics/AbcSize
  def perform
    return if (!Flipper.enabled? :rsvp_nag, member) && (ENV["RAILS_ENV"] == "production")
    return unless member.contactable?
    return unless (@event = RsvpService.new(member).next_pending_event)

    send_text  { |recipient| RsvpNagTexter.new(recipient, event).send_message }
    send_email { |recipient| MemberMailer.with(member: recipient, event_id: @event.id).rsvp_nag_email.deliver_later }
  end
  # rubocop:enable Metrics/AbcSize

  private

  def unit
    @member.unit
  end
end
