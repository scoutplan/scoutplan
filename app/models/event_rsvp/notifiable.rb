# frozen_string_literal: true

module EventRsvp::Notifiable
  extend ActiveSupport::Concern

  included do
    after_save_commit :enqueue_notify_job
  end

  def enqueue_notify_job
    EventRsvpNotification.with(event_rsvp: self).deliver_later(recipients)
  end

  def recipients
    return unit_membership.family if requires_approval?

    [unit_membership]
  end
end
