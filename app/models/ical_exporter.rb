# frozen_string_literal: true

require "icalendar"

# given an Event object, render an Icalendar record
class IcalExporter
  attr_accessor :event

  def initialize(member, event = nil)
    @member = member
    self.event = event
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def to_ical
    ical_event = Icalendar::Event.new
    ical_event.summary = "#{@event.unit.short_name} - #{@event.title}"
    ical_event.summary += " (DRAFT)" if @event.draft?
    ical_event.summary += " (CANCELLED)" if @event.cancelled?
    ical_event.dtstart = @event.starts_at.in_time_zone(@event.unit.time_zone)
    ical_event.dtend = @event.ends_at.in_time_zone(@event.unit.time_zone)
    ical_event.location = [@event.location.presence, @event.address.presence].compact.join(" ")
    ical_event.description = @event.description&.to_plain_text || @event.short_description
    ical_event.url = Rails.application.routes.url_helpers.unit_event_url(@event.unit, @event, host: ENV["APP_HOST"])
    ical_event
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
