# frozen_string_literal: true

require "forwardable"

# a wrapper around Event objects for form input
# see https://nimblehq.co/blog/lets-play-design-patterns-form-objects
class EventView
  include ActiveModel::Model
  extend Forwardable

  attr_accessor :event, :update_scope, :repeats
  attr_writer   :starts_at_date,
                :starts_at_time,
                :ends_at_date,
                :ends_at_time

  # TODO: delegate missing to @event

  def_delegators :@event,
                 :unit,
                 :title,
                 :short_description,
                 :description,
                 :event_category_id,
                 :repeats_until,
                 :location,
                 :address,
                 :departs_from,
                 :requires_rsvp,
                 :rsvp_closes_at,
                 :includes_activity,
                 :activity_name,
                 :new_record?,
                 :save,
                 :save!,
                 :status

  def initialize(event)
    @event = event || new_record
  end

  def starts_at_date
    @event.starts_at.to_date
  end

  def starts_at_time
    @event.starts_at.to_time
  end

  def ends_at_date
    @event.ends_at.to_date
  end

  def ends_at_time
    @event.ends_at.to_time
  end

  def new_record
    raise NotImplementedError
  end

  def assign_attributes(params)
    assign_simple_attributes(params)
    assign_computed_attributes(params)
  end

  private

  def assign_simple_attributes(params)
    @event.assign_attributes(
      params.except(
        :starts_at_date,
        :starts_at_time,
        :ends_at_date,
        :ends_at_time,
        :repeats
      )
    )
  end

  def assign_computed_attributes(params)
    @event.repeats_until = nil unless params[:event_repeats] == "on"

    if params[:starts_at_date].present? && params[:starts_at_time].present?
      @event.starts_at = compose_datetime(params[:starts_at_date], params[:starts_at_time])
    end

    if params[:ends_at_date].present? && params[:ends_at_time].present?
      @event.ends_at = compose_datetime(params[:ends_at_date], params[:ends_at_time])
    end
  end

  def assign_date_time_attribs
    @event.starts_at = compose_datetime(starts_at_date, starts_at_time).utc
    @event.ends_at = compose_datetime(ends_at_date, ends_at_time).utc
  end

  # Holy sh*t timezones are hard! This post shed light on how to parse *into*
  # the current zone. Otherwise everything is UTC.
  # https://rubyinrails.com/2018/05/30/rails-parse-date-time-string-in-utc-zone/
  def compose_datetime(date_str, time_str)
    str = "#{date_str} #{time_str}"
    Time.zone.parse(str) # parse into the current zone
  end
end
