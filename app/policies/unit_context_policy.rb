# frozen_string_literal: true

# Superclass for downstream policies (e.g. Event, Members, etc.)
# TODO: refactor this into a concern or module
class UnitContextPolicy < ApplicationPolicy
  def initialize(*args)
    super(*args)
    @membership = user
  end

  protected

  def admin?
    @membership&.role == "admin"
  end
end
