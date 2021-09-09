class UnitMembershipsController < ApplicationController
  before_action :find_unit, only: [:index]
  before_action :find_membership, except: [:index]

  def index
    authorize :unit_membership
    @unit_memberships = @unit.unit_memberships.includes(:user)
  end

  def show
    authorize @target_membership
    @user = @target_membership.user
  end

  def pundit_user
    @membership
  end

private

  def find_membership
    @target_membership = UnitMembership.find(params[:id])
    @unit = @display_unit = @target_membership.unit
    @membership = @unit.membership_for(current_user)
  end

  def find_unit
    @unit = Unit.find(params[:unit_id])
    @display_unit = @unit
    @membership = @unit.membership_for(current_user)
  end
end
