module EventRsvp::Notifiable
  RUN_TIME = 19 # 7pm

  extend ActiveSupport::Concern

  included do
    before_save :enqueue_organization_notification, if: :send_organizer_notification?
    after_save_commit :enqueue_confirmation
  end

  private

  def confirmation_recipients
    return unit_membership.family if requires_approval? # <- code smell

    [unit_membership]
  end

  def enqueue_organization_notification
    EventRsvpOrganizerNotificationJob.set(wait_until: send_organizer_notification_at).perform_later(event)
  end

  def enqueue_confirmation
    EventRsvpConfirmation.with(event_rsvp: self).deliver_later(confirmation_recipients)
  end

  def send_organizer_notification_at
    Time.zone = unit.time_zone
    Time.current.next_occurrence_of(hour: RUN_TIME).utc
  end

  def send_organizer_notification?
    event.event_rsvps.recent.count.zero?
  end
end
