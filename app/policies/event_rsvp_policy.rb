# frozen_string_literal: true

# Policy class governing Events and what members can do with them
class EventRsvpPolicy < UnitContextPolicy
  attr_accessor :membership, :rsvp, :event

  def initialize(membership, rsvp)
    super
    @membership = membership
    @rsvp = rsvp
    @event = @rsvp.event
  end

  def destroy?
    admin? || organizer?
  end

  def edit?
    create?
  end

  # the ability to RSVP is determined by a number of factors
  def create?(for_member = nil)
    for_member ||= rsvp.member

    # admins can respond for anyone
    return true if admin? || organizer? || event.organizer?(membership)

    # a parent can respond for their children
    return true if @membership.children.include?(for_member)

    # a youth member can respond for themselves if the event, unit, and membership allow it
    return true if for_member == @membership && for_member.youth? && for_member.allow_youth_rsvps? &&
                   rsvp.event.allow_youth_rsvps? && rsvp.unit.allow_youth_rsvps?

    false
  end
end
