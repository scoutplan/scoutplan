# frozen_string_literal: true

require "icalendar"

# given an Event object, render an Icalendar record
class IcalExporter
  attr_accessor :event

  def initialize(member)
    @member = member
  end

  # rubocop:disable Metrics/AbcSize
  def to_ical
    event = Icalendar::Event.new
    event.summary = @event.title
    event.dtstart = @event.starts_at.in_time_zone(@event.unit.time_zone)
    event.dtend = @event.ends_at.in_time_zone(@event.unit.time_zone)
    event.location = [@event.location.presence, @event.address.presence].compact.join(" ")
    event.description = @event.description&.to_plain_text || @event.short_description
    event.url = Rails.application.routes.url_helpers.unit_event_url(@event.unit, @event, host: ENV["APP_HOST"])
    event
  end
  # rubocop:enable Metrics/AbcSize
end
