# frozen_string_literal: true

# controller for handling base URL naviations. For now it just
# bounces the user to the most recent or first Unit they're a member of
class HomeController < ApplicationController
  # GET /
  def index
    current_unit_id = cookies[:current_unit_id]
    redirect_to unit_path(Unit.find(current_unit_id) || current_user.unit_memberships.first.unit)
  end
end
