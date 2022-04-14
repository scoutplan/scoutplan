# frozen_string_literal: true

# controller for handling base URL naviations. For now it just
# bounces the user to the most recent or first Unit they're a member of
class HomeController < ApplicationController
  # before_action :configure_ahoy

  # GET /
  def index
    unit_id = cookies[:current_unit_id] || current_user.unit_memberships.first.unit.id
    redirect_to Unit.find(unit_id)
  end

  # def configure_ahoy
  #   Ahoy.user_method = nil
  # end
end
