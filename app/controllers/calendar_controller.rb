# frozen_string_literal: true

require "icalendar"
require "icalendar/tzinfo"

# given a MagicLink token, renders an iCal enumeration of unit events
class CalendarController < ApplicationController
  skip_before_action :authenticate_user!
  layout false

  # GET /units/:unit_id/events/feed/:token.ics
  def index
    magic_link = MagicLink.find_by(token: params[:token])
    render file: "#{Rails.root}/public/404.html", status: :not_found and return unless magic_link

    member = magic_link.member
    unit = member.unit
    events = UnitEventQuery.new(member, unit).execute

    # create the icalendar
    cal = Icalendar::Calendar.new
    cal.append_custom_property("X-WR-CALNAME", unit.name)

    # well, this is ugly
    unit_timezone = ActiveSupport::TimeZone.new(unit.time_zone)
    tzid = unit_timezone.tzinfo.name
    tz = TZInfo::Timezone.get tzid
    timezone = tz.ical_timezone events.first.starts_at
    cal.add_timezone timezone

    exporter = IcalExporter.new(member)
    exporter.tzid = tzid
    events.each do |event|
      exporter.event = event
      # next unless event.published?

      cal.add_event(exporter.to_ical)
    end

    render plain: cal.to_ical, content_type: "text/calendar"
  end
end
