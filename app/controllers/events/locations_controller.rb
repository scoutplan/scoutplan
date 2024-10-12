# frozen_string_literal: true

module Events
  # dedicated Locations controller for use within the Events form.
  # responds with a Turbo stream to update the Event form.
  class LocationsController < UnitContextController
    def create
      event = Event.find(params[:event_id])
      event_location = event.event_location.new(event_location_params)
      render turbo_stream: [
        turbo_stream.append(:event_locations, partial: "events/locations/event_location", locals: { event_location: event_location })
      ]
    end

    private

    def event_location_params
      params.require(:event_location).permit(:location_id, :location_type)
    end
  end
end
