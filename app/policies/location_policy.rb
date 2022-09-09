# frozen_string_literal: true

# Policy for accessing an Location object
class LocationPolicy < UnitContextPolicy
  def initialize(member, location)
    @member = member
    @location = location
    super
  end

  def edit?
    # defer to Event policy
    true if (@location.locatable.is_a? Event) && EventPolicy.new(@member, @location.locatable).edit?
  end

  def update?
    edit?
  end
end
