class HomeController < ApplicationController
  # skip_before_action :authenticate_user!

  def index
    return unless current_user.present?

    # skip inactive memberships, otherwise UnitContextController bounces us right back here
    unit = current_user.unit_memberships.excluding_inactive.first&.unit
    redirect_to unit_events_path(unit) and return if unit

    sign_out current_user
    redirect_to new_user_session_path, alert: "You don't have an active membership."
  end
end
