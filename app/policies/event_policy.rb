class EventPolicy < UnitContextPolicy
  def initialize(membership, event)
    @membership = membership

ap '^^^^^'
ap @membership

    @event = event
  end

  def show?

puts '$$$$$'
ap @membership

    @event.published? || is_admin?
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

  def publish?
    is_admin?
  end
end
