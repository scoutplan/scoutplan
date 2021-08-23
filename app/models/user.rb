class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
  # devise :omniauthable, omniauth_providers: %i[cognito-idp]

  has_many :event_rsvps
  has_many :unit_memberships
  has_many :parent_relationships, foreign_key: 'child_id', class_name: 'UserRelationship'
  has_many :child_relationships, foreign_key: 'parent_id', class_name: 'UserRelationship'
  # has_many :parents, through: :parent_relationships
  # has_many :children, through: :child_relationships

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
    children.append(self)
  end
end
