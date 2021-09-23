# frozen_string_literal: true

class UserRelationship < ApplicationRecord
  belongs_to :parent, class_name: 'User'
  belongs_to :child, class_name: 'User'
  validates_uniqueness_of :parent, scope: :child
  validates_presence_of :parent, :child
  validate :relation_cannot_be_self

  def relation_cannot_be_self
    errors.add(:parent, "can't reference itself") if parent == child
  end
end
