# frozen_string_literal: true

module EventRsvp::Notifiable
  extend ActiveSupport::Concern

  included do
    after_save :create_notify_job
  end

  def create_notify_job
    SendEventRsvpNotificationJob.perform_later(self)
  end

  def notify!
    EventRsvpNotification.with(event_rsvp: self).deliver_later(member)
  end
end
