class UnitsController < UnitContextController
  def show
    redirect_to unit_events_path(current_unit)
  end

  def update
    authorize current_unit
    current_unit.update(unit_params) if params[:unit].present?
    current_unit.update_settings(settings_params) if params[:settings].present?
    schedule_jobs
    # UnitTaskService.new(current_unit).setup_tasks_from_settings
    redirect_to unit_settings_path(current_unit), notice: I18n.t("settings.notices.update_success")
  end

  def start; end

  def welcome; end

  private

  def unit_params
    return unless params[:unit].present?

    params.require(:unit).permit(:name, :location, :logo, :email, :slug, :allow_youth_rsvps)
  end

  def schedule_jobs
    SendWeeklyDigestJob.schedule_next_job(current_unit)
    RsvpNagJob.schedule_next_job(current_unit)
  end

  def settings_params
    params.require(:settings).permit! # WARNING: the bang lets all [:settings][] params through
  end
end
