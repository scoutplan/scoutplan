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

  def edit_rsvps?
    true
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

  def rsvps?
    admin? || @membership.event_organizer? || @event.organizers.include?(@membership)
  end

  def organize?
    rsvps?
  end

  def publish?
    admin?
  end

  def rsvp?
    @membership.adult?
  end

  def plan?
    admin?
  end

  def cancel?
    admin?
  end

  def delete?
    destroy?
  end

  def destroy?
    admin?
  end
end
