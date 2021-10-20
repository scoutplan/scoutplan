# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    memberships = current_user.unit_memberships

    # redirect_to unit_events_path(memberships.first.unit) if memberships.count == 1
    unit = memberships.first.unit
    redirect_to unit_home_path(unit_id: unit.id, slug: unit.slug)

    # TODO: disambiguate unit
  end
end
