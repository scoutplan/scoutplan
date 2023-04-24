# frozen_string_literal: true

# things for handling messages
class MessageService < ApplicationService
  def initialize(message)
    @message = message
    super()
  end

  # determine which members should receive the current message
  def resolve_members
    members = resolve_member_cohort if @message.member_cohort?
    members = resolve_event_cohort  if @message.event_cohort?
    members.select!(&:adult?) if @message.member_type == "adults_only"
    members
  end

  # return the Event associated with a message, or nil if it's not an event-based Message
  def event
    return nil unless @message.event_cohort?

    recipient_parts = @message.recipients.split("_")
    event_id = recipient_parts.second
    Event.find(event_id)
  end

  private

  def resolve_member_cohort
    @message.author.unit.members.select do |member|
      member.status_active? || (!member.status_inactive? && @message.recipients == "all_members")
    end
  end

  def resolve_event_cohort
    adults_only = @message.member_type == "adults_only"
    acceptors = event.rsvps.accepted.map(&:member)
    acceptors.select!(&:adult?) if adults_only
    parents = adults_only ? [] : acceptors.map(&:parents).flatten
    (acceptors + parents).uniq
  end
end
