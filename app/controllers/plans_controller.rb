class PlansController < UnitContextController
  def index
    @category_names = ['Troop Meeting', 'No Meeting', 'Camping Trip']
    @event_categories = @current_unit.event_categories.where('name IN (?)', @category_names)
    @events = @current_unit.events.published.future.where(event_category: @event_categories)
  end

  def event_activity_params
    params.require(:event_activity).permit(:position)
  end
end
