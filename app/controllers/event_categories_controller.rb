# frozen_string_literal: true

# controller for manipulating EventCategories
class EventCategoriesController < UnitContextController
  def new
    @category = EventCategory.new
  end

  def create
    @category = current_unit.event_categories.new(event_category_params)
    return unless @category.save!

    redirect_to edit_unit_settings_path(@unit)
  end

  private

  def event_category_params
    params.require(:event_category).permit(:name, :glyph, :color)
  end
end
