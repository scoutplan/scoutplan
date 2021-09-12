# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    memberships = current_user.unit_memberships

    redirect_to unit_events_path(memberships.first.unit) if memberships.count == 1

    # TODO: disambiguate unit
  end
end
