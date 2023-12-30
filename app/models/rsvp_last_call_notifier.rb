# frozen_string_literal: true

# A Notifier class for reminding Members when an event's RSVPs are closing soon
class RsvpLastCallNotifier < ApplicationNotifier
  attr_accessor :member

  def initialize(member)
    @member = member
    super()
  end

  # rubocop:disable Metrics/AbcSize
  def perform
    return unless member.contactable?

    # @events = RsvpService.new(member).expiring_rsvp_events
    @events = member.unit.events.published.future.rsvp_required.rsvp_expiring_soon
    return unless @events.present?

    send_text  { |recipient| RsvpLastCallTexter.new(recipient, @events).send_message }
    send_email { |recipient| MemberMailer.with(member: recipient, event_ids: @events.map(&:id)).rsvp_last_call_email.deliver_later }
  end
  # rubocop:enable Metrics/AbcSize

  def contactable
    member
  end
end
