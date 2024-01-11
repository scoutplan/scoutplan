module EventRsvp::Notifiable
  RUN_TIME = 19 # 7pm

  extend ActiveSupport::Concern

  included do
    after_save_commit :enqueue_notifications
  end

  private

  def confirmation_recipients
    return unit_membership.family if requires_approval?

    [unit_membership]
  end

  def enqueue_notifications
    EventRsvpConfirmation.with(event_rsvp: self).deliver_later(confirmation_recipients)
    return unless send_organizer_notification?

    EventRsvpOrganizerNotificationJob.set(wait_until: 1.day.from_now).perform_later(event)
  end

  def send_organizer_notification_at
    Time.zone = unit.time_zone
    DateTime.current.next_occurence_of(hour: RUN_TIME).utc
  end

  def send_organizer_notification?
    event.event_rsvps.recent.count == 1
  end
end
