# frozen_string_literal: true

require "icalendar"

module Event::Icalendarable
  extend ActiveSupport::Concern

  FILE_EXTENSION_ICAL = ".ics"

  def to_ical
    cal = Icalendar::Calendar.new
    cal.append_custom_property("METHOD", "PUBLISH")
    cal.add_event(to_ical_event)
    cal.to_ical
  end

  def to_ical_event
    ical_event = Icalendar::Event.new
    ical_event.summary     = ical_title
    ical_event.dtstart     = ical_starts_at
    ical_event.dtend       = ical_ends_at
    ical_event.location    = online ? website : full_address
    ical_event.description = description&.to_plain_text || short_description
    ical_event.url         = Rails.application.routes.url_helpers.unit_event_url(unit, id, host: ENV.fetch("APP_HOST"))

    ical_event.append_custom_property("ORGANIZER", "CN=#{unit.name}")

    add_alarms(ical_event)

    ical_event
  end

  def ical_filename
    "#{unit.name} #{title} on #{starts_at.strftime('%b %-d %Y')}#{FILE_EXTENSION_ICAL}"
  end

  def ical_title
    res = "#{unit.short_name} - #{title}"
    res += " (DRAFT)" if draft?
    res += " (CANCELLED)" if cancelled?
    res
  end

  def add_alarms(ical_event)
    ical_event.alarm do |a|
      a.action = "DISPLAY"
      a.summary = ical_event.summary
      a.trigger = "-PT1H" # 1 hour before
    end
  end

  def ical_starts_at
    return ical_date(starts_at.in_time_zone(unit.time_zone).beginning_of_day) if all_day?

    ical_datetime(starts_at)
  end

  def ical_ends_at
    return ical_date(ends_at.in_time_zone(unit.time_zone).end_of_day) if all_day?

    ical_datetime(ends_at)
  end

  def ical_date(val)
    Icalendar::Values::Date.new(val.utc, tzid: "UTC")
  end

  def ical_datetime(val)
    Icalendar::Values::DateOrDateTime.new(val.utc, tzid: "UTC")
  end
end
