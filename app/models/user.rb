# frozen_string_literal: true

class User < ApplicationRecord
  include Flipper::Identifier

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :invitable

  has_many :event_rsvps, dependent: :destroy
  has_many :unit_memberships, dependent: :destroy
  has_many :parent_relationships, foreign_key: 'child_id', class_name: 'UserRelationship', dependent: :destroy
  has_many :child_relationships, foreign_key: 'parent_id', class_name: 'UserRelationship', dependent: :destroy
  has_many :rsvp_tokens, dependent: :destroy

  validates_presence_of :type

  def full_name
    "#{first_name} #{last_name}"
  end

  def parents
    parent_relationships.map(&:parent)
  end

  def children
    child_relationships.map(&:child)
  end

  def family
    children.append(self).sort_by(&:first_name)
  end
end
