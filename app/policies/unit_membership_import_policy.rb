class UnitMembershipImportPolicy < UnitContextPolicy
  def initialize(*args)
    ap args
    super(*args)
  end

  def new?
    admin?
  end

  def create?
    admin?
  end
end
