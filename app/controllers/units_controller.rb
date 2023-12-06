class UnitsController < UnitContextController
  def show
    redirect_to unit_events_path(@unit)
  end

  def update
    authorize @unit
    @unit.update(unit_params) if params[:unit].present?
    @unit.update_settings(settings_params) if params[:settings].present?
    UnitTaskService.new(@unit).setup_tasks_from_settings
    redirect_to unit_settings_path(@unit), notice: I18n.t("settings.notices.update_success")
  end

  def start; end

  def welcome; end

  private

  def unit_params
    return unless params[:unit].present?

    params.require(:unit).permit(:name, :location, :logo, :email, :slug, :allow_youth_rsvps)
  end

  def settings_params
    params.require(:settings).permit! # WARNING: the bang lets all [:settings][] params through
  end
end
