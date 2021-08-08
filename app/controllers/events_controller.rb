class EventsController < UnitContextController
  def index
    @unit          = current_unit
    @events        = @unit.events
  end
end
