class EventReadiness
  attr_reader :unit_membership, :event

  def initialize(unit_membership, event)
    current_unit_membership = unit_membership
    @event = event
    @rsvp = event.rsvps.find_by(unit_membership: unit_membership)
  end

  def status
    return :no_response unless @rsvp

    result = []
    result << :no_response unless responded?
    result << :payment_due if payment_due?

    result.empty? ? :ready : result
  end

  def responded?
  end

  def payment_due?
    return false unless event.requires_payment?
    return false unless @rsvp.accepted? || @rsvp.accepted_pending?

    balance_due.positive?
  end
end
