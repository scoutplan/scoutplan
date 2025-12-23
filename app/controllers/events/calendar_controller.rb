# frozen_string_literal: true

module Events
  class CalendarController < UnitContextController
    before_action :authenticate_user!, unless: -> { current_unit.public_calendar? }
    before_action :set_calendar_dates

    def show
      month = params[:month] || cookies[:calendar_month] || Date.today.month
      year = params[:year] || cookies[:calendar_year] || Date.today.year

      unless params[:year] && params[:month]
        redirect_to calendar_unit_events_path(current_unit, year: year, month: month) and return
      end

      cookies[:event_index_variation] = "calendar"
      cookies[:calendar_year] = year
      cookies[:calendar_month] = month
      @events = scope_for_calendar.all

      render "events/calendar"
    end

    def threeup
      @query_year = params[:year]&.to_i || Date.current.year
      @query_month = params[:month]&.to_i || Date.current.month
      @start_date = Date.new(@query_year, @query_month, 1)
      @end_date = (@start_date + 3.months).end_of_month
      @back_date = Date.new(@query_year, @query_month, 1) - 3.months
      @forward_date = Date.new(@query_year, @query_month, 1) + 3.months

      cookies[:event_index_variation] = "threeup"
      find_threeup_events

      render "events/threeup"
    end

    private

    def set_calendar_dates
      @current_year  = params[:year]&.to_i || Date.today.year
      @current_month = params[:month]&.to_i || Date.today.month
      @display_month = params[:display_month]&.to_i
      @display_year  = params[:display_year]&.to_i
      @start_date    = Date.new(@current_year, @current_month, 1)
      @end_date      = @start_date.end_of_month.end_of_day
      @next_month    = @end_date.next_month.beginning_of_month
      @last_month    = @start_date.prev_month
    end

    def scope_for_calendar
      scope = current_unit.events
      scope = scope.published unless EventPolicy.new(current_member, current_unit).view_drafts?
      scope.where("starts_at BETWEEN ? AND ?", @start_date - 1.week, @end_date + 1.week)
    end

    def find_threeup_events
      scope = current_unit.events.includes([event_locations: :location], :tags, :event_category, :event_rsvps)
      scope = scope.published unless EventPolicy.new(current_member, current_unit).view_drafts?
      scope = scope.where("ends_at > ? AND starts_at < ?", @start_date.beginning_of_month, @end_date)
      scope.order(starts_at: :asc)
      @events = scope.all
    end
  end
end
