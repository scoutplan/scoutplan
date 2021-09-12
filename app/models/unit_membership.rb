# frozen_string_literal: true

class UnitMembership < ApplicationRecord
  belongs_to :unit
  belongs_to :user, class_name: 'User'
  validates_uniqueness_of :user, scope: :unit
  alias_attribute :member, :user
  enum status: { inactive: 0, active: 1 }
  delegate :full_name, to: :user

  def admin?
    role == 'admin'
  end
end
