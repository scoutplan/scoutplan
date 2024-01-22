class RsvpLastCallJob < ApplicationJob
  queue_as :default

  attr_reader :event

  def perform(**args)
    return unless should_run?

    @event = args[:event]
    RsvpLastCallNotification.with(event: event).deliver_later(recipients)
  end

  private

  def recipients
    event.non_respondents
  end

  def should_run?
    event.rsvp_open?
  end
end
