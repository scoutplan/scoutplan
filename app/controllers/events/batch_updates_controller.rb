# frozen_string_literal: true

module Events
  # Applies a single attribute change to several events at once. Driven by the Published toggle on
  # the spreadsheet view (see spreadsheet_row_controller#changeEventStatus).
  class BatchUpdatesController < UnitContextController
    def create
      @events = current_unit.events.where(id: event_ids).to_a

      return head :unprocessable_entity if @events.empty? || new_status.blank?

      ActiveRecord::Base.transaction do
        @events.each do |event|
          authorize event, :publish?
          event.update!(status: new_status)
        end
      end
    end

    private

    def event_ids
      params[:event_ids].to_s.split(",").map(&:strip).reject(&:blank?)
    end

    # :status is the only batch-updatable attribute. The previous permit list also included :name,
    # :start_date and :end_date, none of which are Event columns; :location, which is a read-only
    # helper over primary_location; and :description, which is ActionText, so the old update_all
    # would have written the legacy events.description column instead.
    def event_params
      params.require(:event).permit(:status)
    end

    def new_status
      @new_status ||= event_params[:status].presence_in(Event.statuses.keys)
    end
  end
end
