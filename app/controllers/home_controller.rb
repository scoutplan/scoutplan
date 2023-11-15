class HomeController < ApplicationController
  def index
    unit_id = cookies[:current_unit_id].presence || current_user.unit_memberships.first.unit.id
    unit = Unit.find_by(id: unit_id)
    redirect_to unit_events_path(unit_id) and return if unit

    sign_out current_user
  end
end
