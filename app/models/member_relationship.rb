# frozen_string_literal: true

# mapping between UnitMemberships
class MemberRelationship < ApplicationRecord
  belongs_to :parent_unit_membership, class_name: 'UnitMembership'
  belongs_to :child_unit_membership, class_name: 'UnitMembership'
  alias_attribute :parent_member, :parent_unit_membership
  alias_attribute :child_member, :child_unit_membership
  validates_uniqueness_of :parent_unit_membership, scope: :child_unit_membership
  validates_presence_of :parent_unit_membership, :child_unit_membership
  validate :cannot_self_reference

  def cannot_self_reference
    errors.add(:parent, "can't reference itself") if parent_member == child_member
  end

  # def parent
  #   parent_member.user
  # end

  # def child
  #   child_member.user
  # end
end
