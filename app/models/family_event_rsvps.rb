class FamilyEventRsvps
  attr_reader :unit_membership, :event

  def initialize(unit_membership, event)
    @unit_membership, @event = unit_membership, event
  end

  def family
    @family ||= unit_membership.family
  end

  def rsvps
    @rsvps ||= event.family_event_rsvps.where(unit_membership: unit_membership)
  end
end
