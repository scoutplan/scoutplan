# frozen_string_literal: true

# responsible for Unit <> User relationships
class UnitMembershipsController < ApplicationController
  before_action :find_unit, only: %i[index new create]
  before_action :find_membership, except: %i[index new create]

  def index
    authorize :unit_membership
    @unit_memberships = @unit.memberships.includes(:user)
    @membership = @unit.memberships.new
  end

  def show
    authorize @target_membership
    @user = @target_membership.user
    @new_membership = UnitMembership.new
  end

  def pundit_user
    @current_membership
  end

  def new
    authorize :unit_membership
  end

  private

  def find_membership
    @target_membership = UnitMembership.find(params[:id])
    @current_unit = @unit = @target_membership.unit
    @current_membership = @unit.membership_for(current_user)
  end

  def find_unit
    @current_unit = @unit = Unit.find(params[:unit_id])
    @current_membership = @unit.membership_for(current_user)
  end
end
