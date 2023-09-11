# frozen_string_literal: true

# things for handling messages
class MessageService < ApplicationService
  EVENT_REGEXP = /event_(\d+)_attendees/
  TAG_REGEXP = /tag_(\d+)_members/

  def initialize(message)
    @message = message
    super()
  end

  # # determine which members should receive the current message
  # def resolve_members_old
  #   members = resolve_member_cohort if @message.member_cohort?
  #   members = resolve_event_cohort  if @message.event_cohort?
  #   members.select!(&:adult?) if @message.member_type == "adults_only"
  #   members
  # end

  # determine which members should receive the current message
  def resolve_members
    audience      = @message.audience
    member_type   = @message.member_type == "youth_and_adults" ? %w[adult youth] : %w[adult]
    member_status = @message.member_status == "active_and_registered" ? %w[active registered] : %w[active]
    unit          = @message.unit

    # start building up the scope
    scope = unit.unit_memberships.joins(:user).order(:last_name)
    scope = scope.where(member_type: member_type) # adult / youth

    # filter by audience
    if audience =~ EVENT_REGEXP
      event = Event.find($1)
      scope = scope.where(id: event.rsvps.accepted.pluck(:unit_membership_id))
    elsif audience =~ TAG_REGEXP
      tag = ActsAsTaggableOn::Tag.find($1)
      scope = scope.tagged_with(tag.name)
    else
      scope = scope.where(status: member_status) # active / friends & family
    end

    @recipients = scope.all

    # ensure that parents are included if any children are included
    parent_relationships = MemberRelationship.where(child_unit_membership_id: @recipients.map(&:id))
    parents = UnitMembership.where(id: parent_relationships.map(&:parent_unit_membership_id))
    @recipients += parents

    # de-dupe it
    @recipients.uniq!

    # filter out non-emailable members
    @recipients = @recipients.select { |r| r.contactable?(via: :email) }
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
