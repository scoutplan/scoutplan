class EventRsvpOrganizerNotificationJob < ApplicationJob
  attr_reader :event, :unit

  queue_as :default

  def perform(event)
    return unless event.present?

    @event = event
    @unit = event.unit
    EventRsvpOrganizerNotifier.with(event: event).deliver_later(organizer_recipients)
  end

  discard_on ActiveJob::DeserializationError

  private

  def organizer_recipients
    (event.event_organizers.map(&:unit_membership) + unit.unit_memberships.select do |um|
      um.settings(:communication).receives_all_rsvps == "true"
    end).uniq
  end
end
