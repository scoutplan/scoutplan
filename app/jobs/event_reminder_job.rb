# frozen_string_literal: true

# job to send reminder to unit members
class EventReminderJob < ApplicationJob
  include Notifiable

  queue_as :default

  def perform(event_id, event_updated_at)
    @event = Event.find(event_id)
    return unless @event.present?
    return unless @event.updated_at == event_updated_at

    @event.remind!
  end
end
