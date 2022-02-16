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
    Time.zone = unit.settings(:locale).time_zone
    event = Icalendar::Event.new
    event.summary = @event.title
    event.dtstart = @event.starts_at.utc
    event.dtend = @event.ends_at.utc
    event.location = @event.location
    event.location << @event.address if @event.address.present?
    event.description = @event.description&.to_plain_text || @event.short_description
    event.url = Rails.application.routes.url_helpers.unit_event_url(@event.unit, @unit, host: ENV["APP_HOST"])
    event
  end
  # rubocop:enable Metrics/AbcSize
end
