# frozen_string_literal: true

# namespaced for Event-specific behavior.
# Only applies to #create action.
module Events
  # dedicated Locations controller for use within the Events form.
  # responds with a Turbo stream to update the Event form.
  class LocationsController < UnitContextController
    def create
      @event = current_unit.events.find(params[:event_id]) rescue nil
      @location = current_unit.locations.new(params.require(:location).permit(:name, :map_name, :address, :phone, :website))
      authorize @location
      @location.save!

      respond_to do |format|
        format.turbo_stream
      end
    end
  end
end
