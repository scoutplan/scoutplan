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
    cal = Icalendar::Calendar.new
    exporter = IcalExporter.new(member)
    events.each do |event|
      exporter.event = event
      # next unless event.published?

      cal.add_event(exporter.to_ical)
    end

    render plain: cal.to_ical, content_type: "text/calendar"
  end
end
