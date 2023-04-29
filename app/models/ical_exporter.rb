# frozen_string_literal: true

require "icalendar"

# given an Event object, render an Icalendar record
class IcalExporter
  attr_accessor :event
  attr_accessor :tzid

  def initialize(member, event = nil)
    @member = member
    self.event = event
  end

  # rubocop:disable Metrics/AbcSize
  def to_ical
    ical_event = Icalendar::Event.new
    ical_event.summary = "#{@event.unit.short_name} - #{@event.title}"
    ical_event.summary += " (DRAFT)" if @event.draft?
    ical_event.summary += " (CANCELLED)" if @event.cancelled?
    ical_event.dtstart = Icalendar::Values::DateOrDateTime.new(@event.starts_at.utc, tzid: "UTC")
    ical_event.dtend = Icalendar::Values::DateOrDateTime.new(@event.ends_at.utc, tzid: "UTC")
    ical_event.location = @event.online ? @event.website : @event.full_address
    ical_event.description = @event.description&.to_plain_text || @event.short_description
    ical_event.url = Rails.application.routes.url_helpers.unit_event_url(@event.unit, @event, host: ENV["APP_HOST"])
    ical_event
  end
  # rubocop:enable Metrics/AbcSize
end
