class EventOrganizer < ApplicationRecord
  belongs_to :event
  belongs_to :unit_membership
  enum role: { organizer: "organizer", money: "money" }
  alias_attribute :member, :unit_membership
end
