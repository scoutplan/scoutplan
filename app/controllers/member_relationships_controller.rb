# frozen_string_literal: true

# controller for working with member <> member relationships
class MemberRelationshipsController < ApplicationController
  def create
    parent_member = UnitMembership.find(params[:member_id])
    child_member = UnitMembership.find(params[:child_id])
    relationship = parent_member.child_relationships.new(child_member: child_member)
    return unless relationship.save!

    flash[:notice] = t('members.relationships.success_message',
                       first_name: parent_member.full_name,
                       second_name: child_member.full_name)
    redirect_to member_path(parent_member)
  end

  def destroy
    relationship = MemberRelationship.find(params[:id])
    member = relationship.parent_member
    return unless relationship.destroy!

    flash[:notice] = 'Member relationship was removed'
    redirect_to member_path(member)
  end

  def pundit_user
    @current_member
  end
end
