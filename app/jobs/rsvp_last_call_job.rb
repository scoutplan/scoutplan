class RsvpLastCallJob < ApplicationJob
  queue_as :default

  attr_reader :event

  # See EventReminderJob: the trailing argument is tolerated for jobs queued under the old
  # scheme and ignored. Idempotency comes from the Noticed check below, which is state-based
  # and cannot be broken by an unrelated touch the way comparing updated_at could.
  def perform(event_id, _legacy_timestamp = nil)
    @event = Event.find(event_id)
    return if @event.notifications.where(type: "RsvpLastCallNotifier::Notification").count.positive?
    return unless should_run?

    RsvpLastCallNotifier.with(record: event, event: event).deliver_later(recipients)
  end

  private

  def recipients
    event.non_respondents
  end

  def should_run?
    event.rsvp_open?
  end

end
