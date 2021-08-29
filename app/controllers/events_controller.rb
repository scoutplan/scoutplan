class EventsController < UnitContextController
  before_action :authenticate_user!
  before_action :find_event, except: [:index, :create]

  def index
    @events = UnitEventQuery.new(@unit).execute
    @event = @unit.events.new(
      starts_at: 28.days.from_now,
      ends_at: 28.days.from_now
    )
    @event.starts_at = @event.starts_at.change({ hour: 10 }) # default starts at 10 AM
    @event.ends_at   = @event.ends_at.change({ hour: 16 }) # default ends at 4 PM
    @user_rsvps = current_user.event_rsvps
  end

  def show
    @rsvps = @event.event_rsvps.where(user: current_user)
    @can_edit = policy(@event).edit?
  end

  def create
    authorize :event, :create?
    @event = @unit.events.new(event_params)

    @event.starts_at = ScoutplanUtilities.compose_datetime(params[:starts_at_d], params[:starts_at_t])
    @event.ends_at   = ScoutplanUtilities.compose_datetime(params[:ends_at_d], params[:ends_at_t])

    @event.save!

    create_series(params[:repeats_until]) if params[:event_repeats] == 'on'

    redirect_to [@unit, @event]
  end

  def edit
    authorize(@event).edit?
  end

private
  # before_action hook
  def find_event
    @event = @unit.events.find(params[:id])
    @presenter = EventPresenter.new(@event)
  end

  # permitted parameters
  def event_params
    params.require(:event).permit(
      :title,
      :event_category_id,
      :location,
      :description,
      :requires_rsvp,
      :starts_at_d,
      :starts_at_t,
      :ends_at_d,
      :ends_at_t,
    )
  end

  # create a weekly series based on @event
  def create_series(end_date_str)
    end_date = Date.strptime(end_date_str, '%Y-%m-%d')
    new_event = @event.dup
    new_event.series_parent = @event

    ap new_event

    while new_event.starts_at < end_date
      new_event.starts_at += 7.days
      new_event.ends_at += 7.days
      new_event.save!
      new_event = new_event.dup
    end
  end
end
