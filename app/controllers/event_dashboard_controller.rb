class EventDashboardController < EventContextController
  def index
    @event_dashboard = EventDashboard.new(@event)
    authorize @event_dashboard
  end

  # private

  # def find_event
  #   @event = Event.joins(:payments, event_rsvps: [unit_membership: :user]).find(params[:id])
  # end
end
