class HomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    return unless current_user.present?

    unit_id = current_user.unit_memberships.first.unit.id
    unit = Unit.find_by(id: unit_id)
    redirect_to unit_events_path(unit_id) and return if unit

    sign_out current_user
  end
end
