class UnitMembershipsPolicy < UnitContextPolicy
  def index?
    is_member? && is_admin?
  end

  def create?
    true
  end

  def edit?
    true
  end
end
