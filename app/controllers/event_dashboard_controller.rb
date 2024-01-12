class EventDashboardController < EventContextController
  def index
    ap @event
    @event_dashboard = EventDashboard.new(@event)
    authorize @event_dashboard
  end
end
