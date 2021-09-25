# frozen_string_literal: true

# relates a User to a Unit; serves as
# primary concept of a person in Scoutplan
class UnitMembership < ApplicationRecord
  belongs_to :unit
  belongs_to :user, class_name: 'User'

  validates_uniqueness_of :user, scope: :unit
  validates_presence_of :user, :status

  has_many  :parent_relationships,
            foreign_key: 'child_unit_membership_id',
            class_name: 'MemberRelationship',
            dependent: :destroy

  has_many  :child_relationships,
            foreign_key: 'parent_unit_membership_id',
            class_name: 'MemberRelationship',
            dependent: :destroy

  has_many :rsvp_tokens, dependent: :destroy
  has_many :event_rsvps, dependent: :destroy

  alias_attribute :member, :user

  enum status: { inactive: 0, active: 1 }

  delegate :full_name, to: :user
  delegate :first_name, to: :user

  def admin?
    role == 'admin'
  end

  def parents
    parent_relationships.map(&:parent_member)
  end

  def children
    child_relationships.map(&:child_member)
  end

  def family
    children.append(self).sort_by(&:first_name)
  end
end
