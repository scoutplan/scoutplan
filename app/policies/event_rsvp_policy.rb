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

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  # the ability to RSVP is determined by a number of factors
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def create?(for_member = nil)
    for_member ||= rsvp.member

    # admins, unit organizers, and event organizers can respond for anyone
    return true if admin? || organizer? || event.organizer?(membership)

    # a parent can respond for their children
    return true if @membership.children.include?(for_member)

    # an adult can respond for themselves
    return true if for_member == @membership && for_member.adult?

    # a youth member can respond for themselves if the event, unit, and membership allow it
    return true if for_member == membership && for_member.youth? && for_member.allow_youth_rsvps? &&
                   rsvp.event.allow_youth_rsvps? && rsvp.unit.allow_youth_rsvps?

    false
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity


  def requires_approval?
    rsvp.respondent.youth?
  end

end
