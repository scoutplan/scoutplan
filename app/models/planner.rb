# frozen_string_literal: true

# encapsulation of Planner parameters for a unit
# initialize it with a Unit
class Planner
  def initialize(unit)
    @unit = unit
  end

  def event_category_for(key)
    case key
    when :unit_meeting
      category_name = 'Troop Meeting'
    when :camping_trip
      category_name = 'Camping Trip'
    end

    return nil unless category_name

    @unit.event_categories.find_by(name: category_name)
  end
end