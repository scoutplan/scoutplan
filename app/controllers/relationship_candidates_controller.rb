class RelationshipCandidatesController < ApplicationController
  def create
    @relationship_type = params[:relationship_type]
    @candidate = MemberRelationship.new
    if @relationship_type == "parent"
      @candidate.child_unit_membership_id = params[:related_member_id]
    else
      @candidate.parent_unit_membership_id = params[:related_member_id]
    end
  end
end
