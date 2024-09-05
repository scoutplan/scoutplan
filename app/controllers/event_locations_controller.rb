# frozen_string_literal: true

class EventLocationsController < UnitContextController
  def create
    event_location = EventLocation.new(event_location_params)

    render turbo_stream: [
      turbo_stream.append(:event_locations_list,
                          partial: "events/partials/form/event_location",
                          locals:  { event_location: event_location })
    ]
  end

  private

  def event_location_params
    params.require(:event_location).permit(:location_id, :location_type, :url)
  end
end
