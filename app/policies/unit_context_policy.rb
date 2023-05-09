# frozen_string_literal: true

# Superclass for downstream policies (e.g. Event, Members, etc.)
# TODO: refactor this into a concern or module
class UnitContextPolicy < ApplicationPolicy
  def initialize(*args)
    super(*args)
    @membership = user
  end

  def update?
    admin?
  end

  protected

  def admin?
    @membership&.role == "admin"
  end

  def active?
    @membership&.status_active?
  end

  def organizer?
    @membership&.role == "event_organizer"
  end
end
