# frozen_string_literal: true

class LocationsController < UnitContextController
  before_action :find_location, except: [:index, :new, :create]

  def index
    @locations = current_unit.locations.uniq.sort_by(&:display_name)
  end

  def create
    @location = current_unit.locations.new(location_params)
    authorize_creation
    @location.save!

    respond_to do |format|
      format.html { redirect_to unit_locations_path(current_unit), notice: I18n.t("locations.notices.created") }
      format.turbo_stream
      format.json { render json: location_json(@location), status: :created }
    end
  end

  def destroy
    authorize @location
    @location.destroy
    redirect_to unit_locations_path(current_unit),
      notice: I18n.t("locations.notices.destroyed", location_name: @location.display_name)
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

  # Creating a location from unit settings is an admin job. Creating one while
  # editing an event is part of editing that event, so anyone who may edit the
  # event may add to the address book - otherwise a non-admin organizer hits a
  # dead end mid-form.
  def authorize_creation
    event_id = params[:event_id]
    return authorize @location if event_id.blank?

    authorize current_unit.events.find(event_id), :edit?
  end

  def location_json(location)
    {
      id: location.id,
      name: location.display_name,
      address: location.address,
      geocoded: location.geocoded?,
      needs_detail: location.address.blank?
    }
  end

  # scoped to the unit: an unscoped find let any signed-in member reach another
  # unit's location by id
  def find_location
    @location = current_unit.locations.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :map_name, :address, :phone, :website)
  end
end
