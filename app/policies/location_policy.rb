# frozen_string_literal: true

# Policy for accessing an Location object
class LocationPolicy < UnitContextPolicy
  def initialize(member, location)
    super
    @member = member
    @location = location
  end

  def create?
    edit?
  end

  def edit?
    ap @member
    # defer to Event policy
    (@location.locatable.is_a? Event) && EventPolicy.new(@member, @location.locatable).edit?
  end

  def new?
    edit?
  end

  def update?
    edit?
  end
end
