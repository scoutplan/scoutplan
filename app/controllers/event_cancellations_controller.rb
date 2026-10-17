class EventCancellationsController < UnitContextController
  before_action :find_event

  def new
    @event_cancellation = EventCancellation.new(@event)
  end

  def create
    event_cancellation = EventCancellation.new(@event)
    event_cancellation.assign_attributes(event_cancellation_params)

    if event_cancellation.cancel!
      redirect_to unit_events_path(current_unit), notice: notice_for(event_cancellation)
    else
      redirect_to unit_event_path(current_unit, @event), alert: "The event could not be cancelled."
    end
  end

  private

  def find_event
    @event = current_unit.events.find(params[:event_id])
    authorize @event, :cancel?
  end

  def event_cancellation_params
    params.fetch(:event_cancellation, {}).permit(:message_audience, :message, :cancel_series, :disposition)
  end

  def notice_for(event_cancellation)
    notice = case event_cancellation.disposition
             when "delete" then "Event has been deleted."
             when "unpublish" then "Event has been unpublished."
             else "Event has been cancelled."
             end
    count = event_cancellation.recipients.size
    count.positive? ? "#{notice} Notifying #{count} #{"member".pluralize(count)}." : notice
  end
end
