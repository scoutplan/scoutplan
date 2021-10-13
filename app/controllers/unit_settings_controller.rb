# frozen_string_literal: true

class UnitSettingsController < UnitContextController
  before_action :find_unit

  def edit
    @page_title = [@unit.name, 'Settings']
    authorize @unit, policy_class: UnitSettingsPolicy
  end

  def update
    @unit.logo.attach(params[:unit][:logo])
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
end
