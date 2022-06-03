class EventOrganizersController < UnitContextController
  before_action :find_event

  def index
    authorize EventOrganizer
  end

  def create
    @organizer = @event.organizers.new(event_organizer_params)
    authorize @organizer
    if @organizer.save
    end
  end

  def destroy
    @organizer = EventOrganizer.find(params[:id])
    authorize @organizer
  end

  private

  def find_event
    @event = Event.find(params[:event_id])
  end

  def event_organizer_params
    params.require(:event_organizer).permit(:unit_membership_id)
  end
end
