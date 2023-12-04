class EventReminderJob < ApplicationJob
  include Notifiable

  queue_as :default

  def perform(event_id, event_updated_at)
    @event = Event.find(event_id)
    return unless @event.present?
    return unless @event.updated_at == event_updated_at

    @event.remind!
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "EventReminderJob: #{e.message}"
  end
end
