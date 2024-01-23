class RsvpLastCallJob < ApplicationJob
  queue_as :default

  attr_reader :event, :timestamp

  def perform(event_id, timestamp)
    @event = Event.find(event_id)
    @timestamp = timestamp
    return unless should_run? && latest_version?

    RsvpLastCallNotification.with(event: event).deliver_later(recipients)
  end

  private

  def recipients
    event.non_respondents
  end

  def should_run?
    event.rsvp_open?
  end

  def latest_version?
    timestamp == event.updated_at
  end
end
