class EventsController < UnitContextController
  before_action :authenticate_user!
  before_action :set_unit

  def index
    @events = @unit.events
    @new_event = current_unit.events.new
  end

private
  def set_unit
    @unit   = current_unit
  end
end
