# frozen_string_literal: true

class SendEventRsvpNotificationJob < ApplicationJob
  queue_as :default

  def perform(*args)
    event_rsvp = args[0]
    event_rsvp.notify!
  end
end
