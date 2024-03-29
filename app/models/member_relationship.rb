class MemberRelationship < ApplicationRecord
  belongs_to :parent_unit_membership, class_name: "UnitMembership"
  belongs_to :child_unit_membership, class_name: "UnitMembership"
  validates_uniqueness_of :parent_unit_membership, scope: :child_unit_membership
  validates_presence_of :parent_unit_membership, :child_unit_membership
  validate :cannot_self_reference
  validate :same_unit

  def cannot_self_reference
    errors.add(:parent, "can't reference itself") if parent_unit_membership == child_unit_membership
  end

  def same_unit
    errors.add(:parent, "and Child must be in the same unit") unless parent_unit_membership&.unit == child_unit_membership&.unit
  end
end
