class EventDashboardController < EventContextController
  def index
    @event_dashboard = EventDashboard.new(@event)
    authorize @event_dashboard
  end
end
