# frozen_string_literal: true

module EventRsvp::Notifiable
  extend ActiveSupport::Concern

  included do
    after_commit :enqueue_notify_job
  end

  def enqueue_notify_job
    EventRsvpNotification.with(event_rsvp: self).deliver_later(recipients)
  end

  def recipients
    return member.family if requires_approval?

    [member]
  end
end
