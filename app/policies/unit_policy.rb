# frozen_string_literal: true

# Policy class governing Events and what members can do with them
class UnitPolicy < UnitContextPolicy
  def initialize(membership, event)
    super
    @membership = membership
    @event = event
  end

  def edit?
    admin?
  end
end
