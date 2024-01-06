class FamilyRsvpPolicy < UnitContextPolicy
  attr_accessor :membership, :family_rsvp

  def initialize(membership, family_rsvp)
    super
    @membership = membership
    @family_rsvp = family_rsvp
    @event = @family_rsvp.event
  end

  def new?
    create?
  end

  def create?
    rsvp = EventRsvp.new(event: @event, unit_membership: @membership)
    EventRsvpPolicy.new(@membership, rsvp).create?
  end
end
