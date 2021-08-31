class EventPolicy < UnitContextPolicy
  def create?
    is_admin?
  end

  def edit?
    is_admin?
  end

  def organize?
    is_admin?
  end
end
