class UnitMembershipsController < UnitContextController
  def index
    authorize :unit_memberships
    @unit_memberships = @unit.unit_memberships.includes(:user)
  end
end
