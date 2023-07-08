# frozen_string_literal: true

# linking class between Events and UnitMemberships
# as event organizers
class EventOrganizer < ApplicationRecord
  belongs_to :event
  belongs_to :unit_membership
  belongs_to :assigned_by, class_name: "UnitMembership"
  has_one :user, through: :unit_membership

  after_create_commit :notify_recipient

  enum role: { organizer: "organizer", money: "money" }

  alias_attribute :member, :unit_membership

  delegate_missing_to :user

  accepts_nested_attributes_for :unit_membership

  private

  def notify_recipient
    EventOrganizerAssignmentNotification.with(
      event_organizer: self
    ).deliver_later(unit_membership)
  end
end
