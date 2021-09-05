class EventPolicy < UnitContextPolicy
  def initialize(membership, event)
    super(membership, event)
    @event = event
  end

  def show?
    is_admin? || @event.published?
  end

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
