class HomeController < ApplicationController
  def index
    memberships = current_user.unit_memberships

    if memberships.count == 1
      redirect_to unit_events_path(memberships.first.unit)
    end

    # TODO: disambiguate unit
  end
end
