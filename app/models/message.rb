# frozen_string_literal: true

# represents a communication from a person to one or more recipients
class Message < ApplicationRecord
  belongs_to :author, class_name: "UnitMembership"
  has_one :unit, through: :author
  after_initialize :set_defaults

  # validates_presence_of :title

  alias_attribute :member, :unit_membership

  enum status: { draft: 0, queued: 1, sent: 2, pending: 3 }

  # serialize :recipient_details, Array

  # def author
  #   UnitMembership.unscoped { super }
  # end

  # https://stackoverflow.com/a/56437977/6756943
  def set_defaults
    self&.pin_until ||= 1.week.from_now
  end

  def event_cohort?
    recipients =~ /event_([0-9]+)_attendees/
  end

  def member_cohort?
    !event_cohort?
  end

  def send_now?
    !send_at&.future?
  end

  def active?
    sent? && deliver_via_digest && pin_until > Time.now
  end

  def editable?
    status != "sent"
  end

  def approvers
    unit.unit_memberships.message_approver
  end

  # private

  # def find_unit
  #   @unit = author.unit
  # end
end
