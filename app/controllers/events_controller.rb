class EventsController < UnitContextController
  before_action :authenticate_user!
  before_action :set_unit
  before_action :set_event, except: [:index, :create]

  def index
    @events = UnitEventQuery.new(@unit).execute
    @new_event = @unit.events.new(starts_at: 4.weeks.from_now)
  end

  def show
    @rsvps = @event.event_rsvps.where(user: current_user)
  end

  def create
    @event = @unit.events.new(event_params)

    @event.starts_at = compose_date_time(params[:starts_at_d], params[:starts_at_t])
    @event.ends_at   = compose_date_time(params[:ends_at_d], params[:ends_at_t])

    @event.save!

    redirect_to [@unit, @event]
  end

private
  #
  # make a DateTime from the individual date and time strings posted from the form
  #
  def compose_date_time(date_str, time_str)
    str = "#{date_str} #{time_str}"
    fmt = "%m/%d/%Y %l:%M %p"
    DateTime.strptime(str, fmt)
  end

  def event_params
    params.require(:event).permit(:title, :event_category_id, :location, :description, :requires_rsvp)
  end

  def set_unit
    @unit = current_unit
  end

  def set_event
    @event = @unit.events.find(params[:id])
    @presenter = EventPresenter.new(@event)
  end
end
