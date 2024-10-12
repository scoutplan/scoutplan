class EventCancellationsController < UnitContextController
  def new
    @event = Event.find(params[:event_id])
    @event_cancellation = EventCancellation.new(@event)
  end

  def create
    event = Event.find(params[:event_id])
    event_cancellation = EventCancellation.new(event)
    event_cancellation.assign_attributes(event_cancellation_params)
    event_cancellation.cancel!
    redirect_to unit_events_path(event.unit)
  end

  private

  def event_cancellation_params
    params.require(:event_cancellation).permit(:message_audience, :message, :cancel_series, :disposition)
  end
end
