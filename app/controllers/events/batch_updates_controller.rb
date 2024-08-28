# frozen_string_literal: true

module Events
  class BatchUpdatesController < UnitContextController
    def create
      event_ids = params[:event_ids].split(",")
      params_hash = event_params.to_h
      @events = current_unit.events.where(id: event_ids)

      @events.find_each { |e| e.update(params_hash) }
      # @events.update_all(event_params.to_h)
    end

    private

    def event_params
      params.require(:event).permit(:name, :description, :start_date, :end_date, :location, :status)
    end
  end
end
