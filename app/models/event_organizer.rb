# frozen_string_literal: true

# linking class between Events and UnitMemberships
# as event organizers
class EventOrganizer < ApplicationRecord
  belongs_to :event
  belongs_to :unit_membership
  has_one :user, through: :unit_membership
  enum role: { organizer: "organizer", money: "money" }
  alias_attribute :member, :unit_membership
  delegate_missing_to :user

  accepts_nested_attributes_for :unit_membership
end
