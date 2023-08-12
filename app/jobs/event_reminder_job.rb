# frozen_string_literal: true

# job to send reminder to unit members
class EventReminderJob < ApplicationJob
  include Notifiable

  queue_as :default

  def perform(event_id, event_updated_at)
    @event = Event.find(event_id)

    return unless Flipper.enabled? :event_reminder_jobs, @event.unit
    return unless @event.updated_at == event_updated_at # see https://stackoverflow.com/questions/53373100/rails-5-delete-an-activejob-before-it-gets-performed

    @event.remind!
  end
end
