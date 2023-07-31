# frozen_string_literal: true

# represents a communication from a person to one or more recipients
class Message < ApplicationRecord
  belongs_to :author, class_name: "UnitMembership"
  has_one :unit, through: :author
  after_initialize :set_defaults
  has_many_attached :attachments

  alias_attribute :member, :unit_membership

  enum status: { draft: 0, queued: 1, sent: 2, pending: 3 }

  # https://stackoverflow.com/a/56437977/6756943
  def set_defaults
    self&.pin_until ||= 1.week.from_now
  end

  def event_cohort?
    audience =~ /event_(\d+)_attendees/
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
end
