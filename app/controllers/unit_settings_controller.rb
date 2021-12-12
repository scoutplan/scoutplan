# frozen_string_literal: true

class UnitSettingsController < UnitContextController
  before_action :find_unit

  def edit
    @page_title = [@unit.name, 'Settings']
    if @unit.settings(:communication).weekly_digest
      @schedule = IceCube::Schedule.from_yaml(@unit.settings(:communication).weekly_digest)
    end
    authorize @unit, policy_class: UnitSettingsPolicy
  end

  def update
    @unit.update(unit_params)
    if params.dig(:settings, :utilities, :fire_scheduled_tasks)
      @unit.settings(:utilities).fire_scheduled_tasks = true
    end
    @unit.save!
    redirect_to edit_unit_settings_path(@unit)
  end

  def pundit_user
    @current_member
  end

  private

  def find_unit
    @current_unit = @unit = Unit.find(params[:id])
    @current_member = @unit.membership_for(current_user)
  end

  def unit_params
    params.require(:unit).permit(:name, :location, :logo)
  end
end
