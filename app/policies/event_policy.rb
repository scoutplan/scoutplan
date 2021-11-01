# frozen_string_literal: true

class EventPolicy < UnitContextPolicy
  def initialize(membership, event)
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

  def organize?
    admin?
  end

  def publish?
    admin?
  end

  def rsvp?
    @event.published? && @membership.adult?
  end
end
