class LocationCandidatesController < UnitContextController
  layout "modal"

  def create
    @location = Location.new(location_params)
    render turbo_stream: [
      turbo_stream.append(:modal,
                          partial: "location_candidates/form",
                          locals:  { unit: current_unit, location: @location })
    ]
  end

  private

  def location_params
    params.require(:location).permit(:name, :address, :city, :state, :zip, :country)
  end
end
