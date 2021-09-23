# frozen_string_literal: true

# for maintaining parent/child relationships
class UserRelationshipsController < ApplicationController
  before_action :find_user

  def new
    @user_relationship = UserRelationship.new
    case @target_user.type
    when 'Adult'
      @user_relationship.parent = @target_user
    when 'Youth'
      @user_relationship.child = @target_user
    end

    @candidates = @current_unit.members - [@target_user] - @target_user.children
  end

  def create
    @membership = UnitMembership.find(params[:member_id])
    @parent = @membership.user
    @child = User.find(params[:child_id])
    relationship = @parent.child_relationships.new(child: @child)
    return unless relationship.save!

    redirect_to member_path(@membership)
  end

  def destroy
    @target_membership = UnitMembership.find(params[:member_id])
    @relationship = UserRelationship.find(params[:id])
    return unless @relationship.destroy!

    flash[:notice] = 'User relationship was removed'
    redirect_to member_path(@target_membership)
  end

  def pundit_user
    @current_membership
  end

  private

  def find_user
    @target_membership = UnitMembership.find(params[:member_id])
    @target_user  = @target_membership.user
    @current_unit = @target_membership.unit
    @current_membership = @current_unit.membership_for(current_user)
  end
end
