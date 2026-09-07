# frozen_string_literal: true

# Policy for accessing an Location object
class LocationPolicy < UnitContextPolicy
  def initialize(membership, location)
    super
    @membership = membership
    @location = location
  end

  def index?
    admin?
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

  # ApplicationPolicy#destroy? is false, so this has to be stated explicitly
  def destroy?
    edit?
  end
end
