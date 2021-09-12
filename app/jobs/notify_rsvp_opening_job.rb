# frozen_string_literal: true

class NotifyRsvpOpeningJob < ApplicationJob
  queue_as :default

  def perform(event)
    notifier = EventNotifier.new(event)

    event.unit.members.active.each do |member|
      notifier.rsvp_opening(to: member)
    end
  end
end
