# frozen_string_literal: true

# Policy class governing Events and what members can do with them
class EventOrganizerPolicy < UnitContextPolicy
  def initialize(membership, event)
    super
    @membership = membership
    @event = event
  end

  def index?
    admin?
  end

  def create?
    admin?
  end

  def destroy?
    admin?
  end
end
