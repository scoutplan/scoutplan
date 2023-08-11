# frozen_string_literal: true

# represents a communication from a person to one or more recipients
class Message < ApplicationRecord
  include Notifiable

  belongs_to :author, class_name: "UnitMembership"
  has_one :unit, through: :author
  has_many_attached :attachments

  alias_attribute :member, :unit_membership

  enum status: { draft: 0, queued: 1, sent: 2, pending: 3, outbox: 4 }

  def send_now?
    send_at&.past? && (queued? || outbox?)
  end

  def editable?
    status != "sent"
  end

  def approvers
    unit.unit_memberships.message_approver
  end

  def mark_as_sent!
    update(status: :sent)
  end
end
