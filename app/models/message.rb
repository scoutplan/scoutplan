# frozen_string_literal: true

class Message < ApplicationRecord
  include Notifiable, Replyable, Sendable

  belongs_to :author, class_name: "UnitMembership"

  has_one :unit, through: :author

  has_many :message_recipients, as: :message_receivable, dependent: :destroy

  has_many_attached :attachments

  has_rich_text :body

  has_secure_token

  alias_attribute :member, :unit_membership

  enum status: { draft: 0, queued: 1, sent: 2, pending: 3, outbox: 4 }

  accepts_nested_attributes_for :message_recipients, allow_destroy: true

  def approvers
    unit.unit_memberships.message_approver
  end

  def editable?
    status != "sent"
  end

  def plain_text_body
    return body.to_plain_text if body.respond_to?(:to_plain_text)

    body
  end

  def preview
    plain_text_body.truncate(50)
  end
end
