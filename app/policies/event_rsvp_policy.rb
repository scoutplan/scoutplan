# frozen_string_literal: true

# Policy class governing Events and what members can do with them
class EventRsvpPolicy < UnitContextPolicy
  def initialize(membership, rsvp)
    super
    @membership = membership
    @rsvp = rsvp
  end

  def destroy?
    admin?
  end
end
