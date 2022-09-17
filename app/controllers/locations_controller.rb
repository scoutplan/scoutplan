# frozen_string_literal: true

# Controller for manipulating Location objects
class LocationsController < ApplicationController
  before_action :find_location, except: [:new, :create]
  before_action :find_locatable, except: [:create]
  before_action :find_unit, except: [:create]
  before_action :find_member, except: [:create]
  layout "modal"

  def create
    @location = Location.new
    @location.assign_attributes(location_params)
    @locatable = @location.locatable
    find_unit
    find_member
    authorize @location
    @location.save!
    redirect_to params[:return_path], notice: "Location updated"
  end

  def edit
    authorize @location
    @return_path = edit_unit_event_path(@unit, @locatable)
  end

  def new
    find_locatable
    @location = @locatable.locations.new(key: params[:location_key])
    @return_path = edit_unit_event_path(@unit, @locatable)
    ap @location
    authorize @location
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
  end

  def find_locatable
    @locatable = @location.locatable if @location.present?
    @locatable = Event.find(params[:event_id]) if params[:event_id].present?
  end

  def find_location
    @location = Location.find(params[:id])
  end

  def find_member
    @member = @unit.membership_for(current_user)
  end

  def find_unit
    @unit = @locatable&.unit
  end

  def location_params
    params.require(:location).permit(:locatable_type, :locatable_id, :key,
                                     :name, :address, :city, :state, :postal_code, :phone, :website)
  end
end
