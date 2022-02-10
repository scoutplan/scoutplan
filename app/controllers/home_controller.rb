# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    current_unit_id = cookies[:current_unit_id]
    redirect_to unit_events_path(Unit.find(current_unit_id) || current_user.unit_memberships.first.unit)
  rescue
    redirect_to unit_events_path(current_user.unit_memberships.first.unit)
  end
end
