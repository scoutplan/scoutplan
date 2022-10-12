# frozen_string_literal: true

# Service for duplicating Events
class EventDuplicationService
  def initialize(unit, source_event_id)
    @unit = unit
    @source_event = @unit.events.find(source_event_id)
  end

  def build
    @new_event = @source_event.dup
    @new_event.starts_at = date_add_day_of_week(@source_event.starts_at, 1.year)
    @new_event.ends_at = date_add_day_of_week(@source_event.ends_at, 1.year)
    @new_event.status = :draft
    %w[departure arrival activity].each do |location_type|
      source_location = @source_event.event_locations.find_by(location_type: location_type)&.location
      if source_location.present?
        @new_event.event_locations.find_or_initialize_by(location_type: location_type, location_id: source_location.id)
      else
        @new_event.event_locations.find_or_initialize_by(location_type: location_type)
      end
    end
    @new_event
  end

  # date_add_day_of_week(date, 1.year)
  def date_add_day_of_week(date, interval)
    result = date + interval
    result -= 1.day until result.wday == date.wday
    result
  end
end
