# frozen_string_literal: true

# business logic for Events
class EventCreationService < ApplicationService
  def initialize(unit = nil)
    @unit = unit
    super()
  end

  def create(params)
    @event_view = EventView.new(@unit.events.new)
    @event_view.assign_attributes(params)

    # for some reason this isn't being assigned through assign_attributes,
    # so we'll brute-force it
    @event_view.event.repeats_until = params[:repeats_until]
    return unless @event_view.save!

    create_series if params[:repeats] == "yes"
    @event_view.event
  end

  private

  def create_series
    new_event = @event_view.event.dup
    new_event.series_parent = @event_view.event
    new_event.repeats_until = nil

    while new_event.starts_at < @event_view.event.repeats_until
      new_event.starts_at += 7.days
      new_event.ends_at += 7.days
      new_event.save!
      new_event = new_event.dup
    end
  end
end
