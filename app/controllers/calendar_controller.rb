# frozen_string_literal: true

require "icalendar"
require "icalendar/tzinfo"

# given a member token, returns an ical feed of events for that member's unit
class CalendarController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :find_member, :find_unit, :build_calendar

  layout false

  # GET /units/:unit_id/events/feed/:token.ics
  def index
    render file: "#{Rails.root}/public/404.html", status: :not_found and return unless @member.present?

    events.each do |event|
      next unless policy.show?(event)

      @cal.add_event(event.to_ical_event(@member))
    end

    render plain: @cal.to_ical, content_type: "text/calendar"
  end

  private

  def build_calendar
    @cal = Icalendar::Calendar.new
    @cal.append_custom_property("X-WR-CALNAME", @unit.name) # needed for Microsoft
    @cal.append_custom_property("X-WR-TIMEZONE", tzid) # needed for Google Calendar
  end

  def find_member
    @member = UnitMembership.find_by(token: params[:token])
  end

  def find_unit
    @unit = @member.unit
  end

  def events
    scope = @unit.events.includes(:tags).future.order(starts_at: :asc)
    scope = scope.published unless EventPolicy.new(@member, @unit).view_drafts?
    scope.all
  end

  def policy
    @policy ||= EventPolicy.new(@member)
  end

  def tzid
    unit_timezone = ActiveSupport::TimeZone.new(@unit.time_zone)
    unit_timezone.tzinfo.name
  end
end
