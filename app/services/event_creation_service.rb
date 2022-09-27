# frozen_string_literal: true

# business logic for Events
class EventCreationService < ApplicationService
  def initialize(unit = nil)
    @unit = unit
    super()
  end

  def create(params)
    @event = @unit.events.new
    @event.assign_attributes(params)

    # for some reason this isn't being assigned through assign_attributes,
    # so we'll brute-force it
    @event.repeats_until = params[:repeats_until]
    return unless @event.save!

    create_series if params[:repeats] == "yes"
    @event
  end

  private

  def create_series
    new_event = @event.dup
    new_event.series_parent = @event
    new_event.repeats_until = nil

    while new_event.starts_at < @event.repeats_until
      new_event.starts_at += 7.days
      new_event.ends_at += 7.days
      new_event.save!
      new_event = new_event.dup
    end
  end
end
