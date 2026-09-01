class EventReminderJob < ApplicationJob
  include Notifiable

  queue_as :default

  # The second argument is accepted only so jobs enqueued under the old scheme don't fail on
  # deserialization; it is ignored and can be dropped once none remain queued.
  def perform(event_id, _legacy_timestamp = nil)
    @event = Event.find(event_id)
    return unless @event.present?
    return unless @event.event_category.send_reminders?

    @event.remind!
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "EventReminderJob: #{e.message}"
  end
end
