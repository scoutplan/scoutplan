class UnitMembershipsPolicy < UnitContextPolicy
  def initialize(membership, event)
    super(membership, event)
    @event = event
  end

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
