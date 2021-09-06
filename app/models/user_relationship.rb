class UserRelationship < ApplicationRecord
  belongs_to :parent, class_name: 'User'
  belongs_to :child, class_name: 'User'
  validates_uniqueness_of :parent, scope: :child
  validates_presence_of :parent, :child
end
