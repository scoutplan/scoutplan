class EventPolicy < UnitContextPolicy
  def create?
    is_admin?
  end

  def edit?
    true
  end
end
