# frozen_string_literal: true

# controller for working with member <> member relationships
class MemberRelationshipsController < ApplicationController
  def create
    parent_unit_membership = UnitMembership.find(params[:member_id])
    child_unit_membership = UnitMembership.find(params[:child_id])
    relationship = parent_unit_membership.child_relationships.new(child_unit_membership: child_unit_membership)
    return unless relationship.save!

    flash[:notice] = t("members.relationships.success_message",
                       first_name: parent_unit_membership.full_name,
                       second_name: child_unit_membership.full_name)
    redirect_to member_path(parent_unit_membership)
  end

  def destroy
    relationship = MemberRelationship.find(params[:id])
    member = relationship.parent_unit_membership
    return unless relationship.destroy!

    flash[:notice] = "Member relationship was removed"
    redirect_to member_path(member)
  end

  def pundit_user
    @current_member
  end
end
