# frozen_string_literal: true

require "icalendar"
require "icalendar/tzinfo"

# given a member token, returns an ical feed of events for that member's unit
class CalendarController < ApplicationController
  skip_before_action :authenticate_user!
  layout false

  # GET /units/:unit_id/events/feed/:token.ics
  def index
    member = UnitMembership.find_by(token: params[:token])
    render file: "#{Rails.root}/public/404.html", status: :not_found and return unless member

    @unit = member.unit
    scope = @unit.events.includes(:tags).future.order(starts_at: :asc)
    scope = scope.published unless EventPolicy.new(member, @unit).view_drafts?
    events = scope.all
    unit_timezone = ActiveSupport::TimeZone.new(@unit.time_zone)
    tzid = unit_timezone.tzinfo.name

    # create the icalendar
    cal = Icalendar::Calendar.new
    cal.append_custom_property("X-WR-CALNAME", @unit.name) # needed for Microsoft
    cal.append_custom_property("X-WR-TIMEZONE", tzid) # needed for Google Calendar

    exporter = IcalExporter.new(member)
    policy = EventPolicy.new(member)

    events.each do |event|
      next unless policy.show?(event)

      exporter.event = event
      cal.add_event(exporter.to_ical)
    end

    render plain: cal.to_ical, content_type: "text/calendar"
  end
end
