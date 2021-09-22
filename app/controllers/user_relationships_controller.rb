# frozen_string_literal: true

# for maintaining parent/child relationships
class UserRelationshipsController < ApplicationController
  before_action :find_user

  def new
    @user_relationship = UserRelationship.new
    @user_relationship.parent = @target_user if @target_user.is_a?(Adult)
    @user_relationship.child  = @target_user if @target_user.is_a?(Youth)
    @candidates = @current_unit.members.where('type = ?', :youth)
  end

  def create
    @child = User.find(params[:child_id])
    relationship = @user.child_relationships.new(child: @child)
    return unless relationship.save!
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
    ap @target_membership
  end
end
