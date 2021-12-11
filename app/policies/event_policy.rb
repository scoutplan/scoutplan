# frozen_string_literal: true

# Policy class governing Events and what members can do with them
class EventPolicy < UnitContextPolicy
  def initialize(membership, event)
    super
    @membership = membership
    @event = event
  end

  def show?
    @event.published? || admin?
  end

  def create?
    admin?
  end

  def edit?
    admin?
  end

  def update?
    admin?
  end

  def organize?
    admin?
  end

  def publish?
    admin?
  end

  def rsvp?
    @event.published? && @membership.adult?
  end

  def plan?
    admin?
  end

  def cancel?
    admin?
  end
end
