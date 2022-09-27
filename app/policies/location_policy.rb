# frozen_string_literal: true

# Policy for accessing an Location object
class LocationPolicy < UnitContextPolicy
  def initialize(membership, location)
    super
    @membership = membership
    @location = location
  end

  def create?
    edit?
  end

  def edit?
    admin?
  end

  def new?
    edit?
  end

  def update?
    edit?
  end
end
