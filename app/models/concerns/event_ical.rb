# frozen_string_literal: true

# additional methods for converting Events to iCal format
module EventIcal
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/AbcSize
  def to_ical
    Time.zone = unit.settings(:locale).time_zone
    event = Icalendar::Event.new
    event.summary  = title
    event.dtstart  = starts_at.utc
    event.dtend    = ends_at.utc
    event.location = location
    event.location << address if address.present?
    event.description = description&.to_plain_text || short_description
    event.url = Rails.application.routes.url_helpers.unit_event_url(unit, self, host: ENV["APP_HOST"])
    event
  end
  # rubocop:enable Metrics/AbcSize
end
