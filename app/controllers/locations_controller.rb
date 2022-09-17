# frozen_string_literal: true

# Controller for manipulating Location objects
class LocationsController < ApplicationController
  before_action :create_context
  layout "modal"

  def edit
    authorize @location
    @return_path = edit_unit_event_path(@unit, @locatable)
  end

  def update
    @location = Location.find(params[:id])
    authorize @location
    @location.assign_attributes(location_params)
    @location.save!
    redirect_to params[:return_path], notice: "Location updated"
  end

  def pundit_user
    @member
  end

  private

  def create_context
    @location = Location.find(params[:id])
    @locatable = @location.locatable
    @unit = @locatable&.unit
    @member = @unit.membership_for(current_user)
  end

  def location_params
    params.require(:location).permit(:locatable_type, :locatable_id, :name, :address, :city, :state, :postal_code, :phone, :website)
  end
end
