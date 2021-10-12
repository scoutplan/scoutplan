class EventCategoriesController < ApplicationController
  before_action :find_unit

  def new
    @category = EventCategory.new
  end

  def create
    @category = @unit.event_categories.new(event_category_params)
    return unless @category.save!

    redirect_to edit_unit_settings_path(@unit)
  end

  def pundit_user
    @membership
  end

  private

  def find_unit
    @current_unit = @unit = Unit.find(params[:unit_id])
    @membership = @unit.unit_memberships.find_by(user: current_user)
  end

  def event_category_params
    params.require(:event_category).permit(:name, :glyph, :color)
  end
end
