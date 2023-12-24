class EventDashboardController < EventContextController
  def index
    @event_dashboard = EventDashboard.new(@event)
  end
end
