# frozen_string_literal: true

# Controller for Units
class UnitsController < UnitContextController
  def show
    redirect_to unit_events_path(@unit)
  end

  def update
    authorize @unit
    @unit.assign_attributes(unit_params)
    @unit.save!
    redirect_to unit_setting_path(@unit, category: "unit_profile"), notice: I18n.t("settings.notices.update_success")
  end

  private

  def unit_params
    params.require(:unit).permit(:name, :location, :logo)
  end
end
