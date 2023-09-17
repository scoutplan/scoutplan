# frozen_string_literal: true

require "icalendar"

module Event::Icalendarable
  extend ActiveSupport::Concern

  FILE_EXTENSION_ICAL = ".ics"

  def attendee_params(member)
    {
      cn:           member.full_name,
      cutype:       "INDIVIDUAL",
      role:         "REQ-PARTICIPANT",
      partstat:     "NEEDS-ACTION",
      rsvp:         "TRUE",
      x_num_guests: "0"
    }
  end

  def attendee_value(member)
    Icalendar::Values::Text.new("MAILTO:#{member.email}", attendee_params(member))
  end

  def to_ical(member = nil)
    cal = Icalendar::Calendar.new
    cal.append_custom_property("METHOD", "REQUEST")
    cal.append_custom_property("ATTENDEE", attendee_value(member)) if @member.present? && rsvp_open?
    cal.add_event(to_ical_event(member))
    cal.to_ical
  end

  def to_ical_event(member)
    ical_event = Icalendar::Event.new
    ical_event.summary     = ical_title
    ical_event.dtstart     = ical_starts_at
    ical_event.dtend       = ical_ends_at
    ical_event.location    = online ? website : full_address
    ical_event.description = description&.to_plain_text || short_description
    ical_event.url         = Rails.application.routes.url_helpers.unit_event_url(unit, id, host: ENV.fetch("APP_HOST"))

    ical_event.append_custom_property("ORGANIZER", "CN=#{unit.name}:MAILTO:#{unit.from_address}")
    ical_event.append_custom_property("ATTENDEE", attendee_value(member)) if member.present? && rsvp_open?

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
    return ical_datetime(starts_at.beginning_of_day.in_time_zone) if all_day?

    ical_datetime(starts_at)
  end

  def ical_ends_at
    return ical_datetime(ends_at.end_of_day.in_time_zone) if all_day?

    ical_datetime(ends_at)
  end

  def ical_datetime(val)
    Icalendar::Values::DateOrDateTime.new(val.utc, tzid: "UTC")
  end
end
