class UnitMembershipsController < ApplicationController
  before_action :find_unit

  def index
    authorize :unit_memberships
    @unit_memberships = @unit.unit_memberships.includes(:user)
  end

  def pundit_user
    @membership
  end

private

  def find_unit
    @unit = Unit.find(params[:unit_id])
    @display_unit = @unit
    @membership = @unit.membership_for(current_user)
  end
end
