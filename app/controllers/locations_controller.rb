# frozen_string_literal: true

# Controller for manipulating Location objects
class LocationsController < UnitContextController
  before_action :find_location, except: [:index, :new, :create]

  def index
    @locations = @unit.locations.sort_by(&:display_name)
  end

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

  private

  def find_location
    @location = Location.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:locatable_type, :locatable_id, :key,
                                     :name, :address, :city, :state, :postal_code, :phone, :website)
  end
end
