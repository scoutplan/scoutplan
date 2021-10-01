# frozen_string_literal: true

# a person in Scoutplan. Most business logic, however
# is handled in the UnitMembership class
class User < ApplicationRecord
  include Flipper::Identifier

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_many :unit_memberships, dependent: :destroy
  has_many  :parent_relationships,
            foreign_key: 'child_unit_membership_id',
            class_name: 'MemberRelationship',
            dependent: :destroy
  has_many  :child_relationships,
            foreign_key: 'parent_unit_membership_id',
            class_name: 'MemberRelationship',
            dependent: :destroy

  self.inheritance_column = nil
  enum type: { unknown: 0, youth: 1, adult: 2 }

  def full_name
    "#{first_name} #{last_name}"
  end

  def anonymous_email?
    email.match?(/anonymous-member-\h+@scoutplan.org/)
  end

  def emailable?
    !anonymous_email?
  end

  def contactable?
    emailable?
  end

  def display_first_name
    nickname || first_name
  end
end
