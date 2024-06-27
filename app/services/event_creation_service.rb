# frozen_string_literal: true

class EventCreationService < ApplicationService
  attr_reader :unit

  def initialize(unit = nil)
    @unit = unit
    super()
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def create(params)
    @event = unit.events.new
    @event.assign_attributes(params)

    zone = Time.find_zone!(unit.time_zone)
    @event.starts_at = zone.parse("#{params[:starts_at_date]} #{params[:starts_at_time]}")
    @event.ends_at = zone.parse("#{params[:ends_at_date]} #{params[:ends_at_time]}")

    category_name = params[:event_category_proxy_name]
    unless unit.event_categories.find_or_create_by(name: category_name)
      @event.category = unit.event_categories.create(name: category_name)
    end

    # for some reason this isn't being assigned through assign_attributes,
    # so we'll brute-force it
    @event.repeats_until = params[:repeats_until]
    return @event unless @event.save

    create_series if params[:repeats] == "yes"
    @event
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  private

  def create_category(name)
    category = unit.event_categories.create(name: name)
    @event.category = category
  end

  def create_series
    new_event = @event.dup
    new_event.regenerate_token
    new_event.series_parent = @event
    new_event.repeats_until = nil

    while new_event.starts_at < @event.repeats_until
      new_event.starts_at += 7.days
      new_event.ends_at += 7.days
      new_event.save!

      @event.event_locations.each do |el|
        new_el = el.dup
        new_el.event = new_event
        new_el.save!
      end

      new_event = new_event.dup
      new_event.regenerate_token
    end
  end
end
