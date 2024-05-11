# frozen_string_literal: true

module Events
  class BatchUpdatesController < UnitContextController
    def create
      event_ids = params[:event_ids].split(",")
      @events = current_unit.events.where(id: event_ids)
      @events.update_all(event_params.to_h)
    end

    private

    def event_params
      params.require(:event).permit(:name, :description, :start_date, :end_date, :location, :status)
    end
  end
end
