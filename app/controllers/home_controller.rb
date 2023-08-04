# frozen_string_literal: true

# controller for handling base URL naviations. For now it just
# bounces the user to the most recent or first Unit they're a member of
class HomeController < ApplicationController
  skip_before_action :authenticate_user!

  # GET /
  def index
    unit_id = cookies[:current_unit_id] || current_user.unit_memberships.first.unit.id
    unit = Unit.find(unit_id)
    redirect_to unit
  end
end
