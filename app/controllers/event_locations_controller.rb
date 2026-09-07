# frozen_string_literal: true

class EventLocationsController < UnitContextController
  def create
    authorize_location_change

    event_location = EventLocation.new(event_location_params)

    render turbo_stream: [
      turbo_stream.append(:event_locations_list,
        partial: "events/partials/form/event_location",
        locals: {event_location_counter: Digest::MD5.hexdigest(event_location.location_type).to_i(16),
                 event_location: event_location})
    ]
  end

  private

  # nothing is persisted here - the rendered row carries nested-attribute fields
  # that EventsController#update writes later - but the row does disclose the
  # location's name, so it needs the same gate as editing the event itself.
  # A new event has no id yet, and that form is only reachable by admins.
  def authorize_location_change
    event_id = params.dig(:event_location, :event_id)

    if event_id.present?
      authorize current_unit.events.find(event_id), :edit?
    else
      authorize Event.new(unit: current_unit), :create?
    end
  end

  def event_location_params
    permitted = params.require(:event_location).permit(:location_id, :location_type, :url)
    permitted[:location_id] = scoped_location_id(permitted[:location_id])
    permitted
  end

  # an id belonging to another unit must not resolve
  def scoped_location_id(location_id)
    return if location_id.blank?

    current_unit.locations.find(location_id).id
  end
end
