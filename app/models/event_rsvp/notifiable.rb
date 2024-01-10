module EventRsvp::Notifiable
  RUN_TIME = 19

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
    EventRsvpOrganizerNotification.with(event: event, wait_until: send_organizer_notification_at)
                                  .deliver_later(organizer_recipients)
  end

  def organizer_recipients
    (event.organizers.map(&:unit_membership) + unit.unit_memberships.select do |um|
      um.settings(:communication).receives_all_rsvps == "true"
    end).uniq
  end

  def send_organizer_notification_at
    Time.zone = unit.time_zone
    DateTime.current.change(hour: RUN_TIME, min: 0, sec: 0).utc
  end

  def send_organizer_notification?
    return true

    event.event_rsvps.recent.count == 1
  end
end
