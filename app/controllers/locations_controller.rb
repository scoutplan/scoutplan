# frozen_string_literal: true

# Controller for manipulating Location objects
class LocationsController < UnitContextController
  before_action :find_location, except: [:index, :new, :create]

  def index
    @locations = current_unit.locations.uniq.sort_by(&:display_name)
  end

  def create
    @location = current_unit.locations.new(location_params)
    authorize @location
    @location.save!
    redirect_to unit_locations_path(current_unit), notice: I18n.t("locations.notices.created")
  end

  def destroy
    @location.destroy
    redirect_to unit_locations_path(current_unit), notice: I18n.t("locations.notices.destroyed", location_name: @location.display_name)
  end

  def edit
    authorize @location
    # @location_type = params[:location_type]
    # @event_id = params[:event_id]
  end

  def new
    @location = current_unit.locations.new
    authorize @location
    @event_id = params[:event_id]
    @location_type = params[:location_type]
  end

  def update
    authorize @location
    @location.assign_attributes(location_params)
    @location.save!
    redirect_to params[:return_path] || unit_locations_path(current_unit), notice: I18n.t("locations.notices.updated")
  end

  private

  def find_location
    @location = Location.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :map_name, :address, :phone, :website)
  end
end
