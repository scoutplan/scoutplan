# frozen_string_literal: true

module Events
  class BulkPublicationsController < UnitContextController
    def create
      event_ids = params[:event_ids]
      events = current_unit.events.where(id: event_ids)

      events.each do |event|
        authorize event, :update?
        event.update!(status: :published)
      end

      flash[:notice] = t("events.index.bulk_publish.success_message")
      redirect_to unit_events_path(current_unit)
    end
  end
end
