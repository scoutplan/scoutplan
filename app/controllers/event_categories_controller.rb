# frozen_string_literal: true

# controller for manipulating EventCategories
class EventCategoriesController < UnitContextController
  def create
    @category = current_unit.event_categories.new(event_category_params)
    return unless @category.save!

    respond_to do |format|
      format.html { redirect_to unit_event_categories_path(current_unit), notice: "event_categories.notices.create_success" }
      format.turbo_stream
    end
  end

  def destroy
    find_event_category
    if (replacement_id = params[:replacement][:id]).present?
      current_unit.events.where(event_category_id: @event_category.id).update(event_category_id: replacement_id)
    end

    # @event_category.destroy
    redirect_to unit_event_categories_path(current_unit), notice: "event_categories.notices.destroy_success"
  end

  def edit
    find_event_category
  end

  def new
    @event_category = EventCategory.new
  end

  # GET /units/:unit_id/event_categories/:id/remove
  # interstitial page in case category is in use
  def remove
    find_event_category
    @count = current_unit.events.where(event_category_id: @event_category.id).count
    return if @count.positive?

    @event_category.destroy
    redirect_to unit_event_categories_path(current_unit), notice: "event_categories.notices.destroy_success"
  end

  def update
    find_event_category
    @event_category.assign_attributes(event_category_params)
    @event_category.save!
    redirect_to unit_event_categories_path(current_unit),
                notice: I18n.t("event_categories.notices.update_success", name: @event_category.name)
  end

  private

  def event_category_params
    params.require(:event_category).permit(:name, :glyph, :color, :send_reminders)
  end

  def find_event_category
    @event_category = current_unit.event_categories.find(params[:event_category_id] || params[:id])
  end
end
