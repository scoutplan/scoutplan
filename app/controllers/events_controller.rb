class EventsController < UnitContextController
  before_action :authenticate_user!
  before_action :set_unit
  before_action :set_event, except: [:index, :create]

  def index
    query = UnitEventQuery.new(@unit)
    @events = query.execute

    # @unit = Unit.find(params[:unit_id]).include(events: [:event_rsvp])
    # @events = @unit.events

    @new_event = current_unit.events.new(starts_at: 4.weeks.from_now)
  end

  def show
    @rsvps = @event.event_rsvps.where(user: current_user)
  end

  def create
    @event = @unit.events.new
    @event.save!
    redirect_to [@unit, @event]
  end

private
  def set_unit
    @unit = current_unit
  end

  def set_event
    @event = @unit.events.find(params[:id])
    @presenter = EventPresenter.new(@event)
  end
end
