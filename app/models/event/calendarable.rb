# frozen_string_literal: true

require "icalendar"

module Event::Calendarable
  extend ActiveSupport::Concern

  FILE_EXTENSION_ICAL = ".ics"

  def attendee_params
    {
      cutype:       "INDIVIDUAL",
      role:         "REQ-PARTICIPANT",
      partstat:     "NEEDS-ACTION",
      rsvp:         "TRUE",
      cn:           full_name,
      x_num_guests: "0"
    }
  end

  def to_ical
    cal = Icalendar::Calendar.new
    cal.append_custom_property("METHOD", "REQUEST")
    cal.add_event(to_ical_event)
    cal.to_ical
  end

  def to_ical_event
    ical_event = Icalendar::Event.new
    ical_event.summary     = ical_summary
    ical_event.dtstart     = ical_starts_at
    ical_event.dtend       = ical_ends_at
    ical_event.location    = online ? website : full_address
    ical_event.description = description&.to_plain_text || short_description
    ical_event.url = Rails.application.routes.url_helpers.unit_event_url(unit, id, host: ENV.fetch("APP_HOST"))
    add_alarms(ical_event)

    ical_event
  end

  def ical_filename
    "#{title}#{FILE_EXTENSION_ICAL}"
  end

  def ical_summary
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
    ical_datetime(starts_at)
  end

  def ical_ends_at
    ical_datetime(ends_at)
  end

  def ical_datetime(val)
    Icalendar::Values::DateOrDateTime.new(all_day? ? val.to_date : val.utc, tzid: "UTC")
  end
end
