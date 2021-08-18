class UnitMembership < ApplicationRecord
  belongs_to :unit
  belongs_to :member, class_name: 'User'
  enum status: { inactive: 0, active: 1 }
end
