# frozen_string_literal: true

# namespaced for Event-specific behavior.
module Events
  # an Event-specific AdminController
  class AdminController < UnitContextController
    before_action :find_event

    def index; end

    def remind
      EventReminderNotifier.with(event: @event).deliver_later(current_member)
      redirect_to unit_event_admin_path(current_unit, @event), notice: "Reminder sent!"
    end

    private

    def find_event
      @event = current_unit.events.find(params[:event_id])
    end
  end
end
