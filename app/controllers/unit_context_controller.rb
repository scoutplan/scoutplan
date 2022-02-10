# frozen_string_literal: true

# an abstract controller to be subclassed for instances
# where a Unit is being manipulated (which is to say, most)
class UnitContextController < ApplicationController
  # before_action :find_unit_info, only: %i[index new create]
  before_action :set_unit_cookie

  def current_unit
    Unit.find(params[:unit_id]) if params[:unit_id].present?
  end

  attr_reader :current_membership

  def pundit_user
    @membership
  end

  private

  def find_unit_info
    # TODO: scope this to the current user's memberships
    @current_unit = @unit = Unit.includes(:unit_memberships).find(params[:unit_id])
    @current_member = @membership = @unit.membership_for(current_user)
    Time.zone = @unit.settings(:locale).time_zone
  end

  def set_unit_cookie
    cookies[:current_unit_id] = { value: current_unit&.id }
    ap "$$$$$$$$$$$$$$"
    ap cookies[:current_unit_id]
  end
end
