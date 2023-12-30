class EventDashboardPolicy < UnitContextPolicy
  def initialize(membership, event_dashboard)
    super
    @membership = membership
    @event_dashboard = event_dashboard
    @event = @event_dashboard.event
  end

  def index?
    admin? || @membership.event_organizer? || @event.organizer?(@membership)
  end
end
