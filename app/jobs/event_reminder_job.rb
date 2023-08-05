# job to send reminder to unit members
class EventReminderJob < ApplicationJob
  queue_as :default

  def perform(event_id, event_updated_at)
    event = Event.find(event_id)
    return unless event.updated_at == event_updated_at # don't run if the event has since been updated

    event.remind!
  end
end
