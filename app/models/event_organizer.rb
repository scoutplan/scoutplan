class EventOrganizer < ApplicationRecord
  belongs_to :event, touch: true
  belongs_to :unit_membership
  belongs_to :assigned_by, class_name: "UnitMembership", optional: true
  has_one :user, through: :unit_membership

  after_create_commit :notify_recipient

  enum :role, { organizer: "organizer", money: "money" }

  delegate_missing_to :unit_membership

  accepts_nested_attributes_for :unit_membership

  private

  def notify_recipient
    return unless assigned_by
    return if unit_membership.user == assigned_by.user

    EventOrganizerAssignmentNotifier.with(
      event_organizer: self
    ).deliver_later(unit_membership)
  end
end
