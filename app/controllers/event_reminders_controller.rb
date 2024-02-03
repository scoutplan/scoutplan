# frozen_string_literal: true

class EventRemindersController < UnitContextController
  before_action :find_event

  def create
    EventReminderNotifier.with(event: @event).deliver_later(members)
  end

  private

  def find_event
    @event = Event.find(params[:event_id])
  end

  def members
    [@current_member]
  end
end
