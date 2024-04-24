# frozen_string_literal: true

# manage Unit Plans
class PlansController < UnitContextController
  def index
    @category_names = ["Troop Meeting", "Camping Trip"].freeze
    @event_categories = @current_unit.event_categories.where("name IN (?)", @category_names)
    @events = @current_unit.events.where("starts_at BETWEEN ? AND ?", current_unit.this_season_starts_at, current_unit.next_season_ends_at).includes(:event_category, :event_activities).where(event_category: @event_categories)
  end

  def event_activity_params
    params.require(:event_activity).permit(:position)
  end
end
