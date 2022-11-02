# frozen_string_literal: true

# Service for handling event organizers
class MemberRelationshipService
  attr_accessor :member

  def initialize(member)
    @member = member
  end

  def update(member_relationship_params = {})
    member_relationship_params ||= {}
    create_if_needed(member_relationship_params[:unit_membership_ids])
    delete_unused(member_relationship_params[:unit_membership_ids])
  end

  private

  def create_if_needed(member_ids = [])
    member_ids ||= []
    member_ids.each do |member_id|
      member.child_relationships.find_or_create_by(child_unit_membership_id: member_id.to_i)
    end
  end

  def delete_unused(member_ids = [])
    member_ids ||= []
    member.child_relationships.each do |relationship|
      relationship.destroy unless member_ids.include?(relationship.child_unit_membership_id.to_s)
    end
  end
end
