class UnitMembershipImportPolicy < UnitContextPolicy
  def new?
    admin?
  end

  def create?
    admin?
  end
end
