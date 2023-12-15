# frozen_string_literal: true

class EventContextController < UnitContextController
  before_action :find_event

  private

  def find_event
    @event = @unit.events.find(params[:event_id] || params[:id])
  end
end
