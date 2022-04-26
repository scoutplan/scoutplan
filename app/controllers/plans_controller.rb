# frozen_string_literal: true

# manage Unit Plans
class PlansController < UnitContextController
  layout "application_full_width"

  def index
    @category_names = ['Troop Meeting', 'No Meeting', 'Camping Trip', 'Court of Honor'].freeze
    @event_categories = @current_unit.event_categories.where('name IN (?)', @category_names)
    @events = @current_unit.events.includes(:event_category, :event_activities).published.future.where(event_category: @event_categories)
  end

  def event_activity_params
    params.require(:event_activity).permit(:position)
  end
end
