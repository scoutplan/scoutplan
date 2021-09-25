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
    build_new_relationship
  end

  def pundit_user
    @current_member
  end

  def new
    authorize :unit_membership
  end

  private

  def build_new_relationship
    @member_relationship = MemberRelationship.new(parent_member: @target_membership)
    ap @target_membership.child_relationships

    # possible relationships are any other unit members, minus onesself, minus existing child memberships
    @candidates = @current_unit.memberships -
                  [@target_membership] -
                  @target_membership.child_relationships.collect(&:child_member)
  end

  def find_membership
    @target_membership = UnitMembership.find(params[:id])
    @target_user = @target_membership.user
    @current_unit = @unit = @target_membership.unit
    @current_member = @unit.membership_for(current_user)
  end

  def find_unit
    @current_unit = @unit = Unit.find(params[:unit_id])
    @current_member = @unit.membership_for(current_user)
  end
end
