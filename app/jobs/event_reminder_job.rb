# job to send reminder to unit members
class EventReminderJob < ApplicationJob
  queue_as :default

  def perform(event_id, event_updated_at)
    event = Event.find(event_id)

    ap "I am here"

    # don't run if the event has since been updated
    # see https://stackoverflow.com/questions/53373100/rails-5-delete-an-activejob-before-it-gets-performed
    return unless event.updated_at == event_updated_at

    event.remind!
  end
end
