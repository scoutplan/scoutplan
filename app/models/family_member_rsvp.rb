class FamilyMemberRsvp
  attr_reader :member, :event, :rsvp

  delegate_missing_to :member

  def initialize(member, event)
    @member, @event = member, event
    @rsvp = event.rsvps.find_by(unit_membership: member)
  end

  def response
    return :unknown unless @rsvp

    rsvp.response
  end
end
