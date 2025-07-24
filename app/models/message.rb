# frozen_string_literal: true

class Message < ApplicationRecord
  include Notifiable, Replyable, Sendable, NestedKeys

  belongs_to :author, class_name: "UnitMembership"
  belongs_to :sender, class_name: "UnitMembership"

  has_one :unit, through: :author

  has_many :message_recipients

  has_many_attached :attachments

  has_rich_text :body

  has_secure_token

  enum :status, { draft: 0, queued: 1, sent: 2, pending: 3, outbox: 4 }

  accepts_nested_keys_for :message_recipients, :unit_membership_id

  scope :draft_and_queued, -> { where(status: %i[draft queued]) }

  def approvers
    unit.unit_memberships.message_approver
  end

  def display_title
    title.presence || "(no subject)"
  end

  def editable?
    status != "sent"
  end

  def deleteable?
    !new_record? && editable?
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def dup
    super.tap do |new_message|
      new_message.regenerate_token
      new_message.body = body.dup
      new_message.status = :draft
      new_message.title.prepend("Copy of ")
      new_message.save!

      message_recipients.each do |message_recipient|
        message_recipient.dup.tap do |new_recipient|
          new_recipient.message = new_message
          new_recipient.unit_membership = message_recipient.unit_membership
          new_recipient.save!
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def plain_text_body
    return body.to_plain_text if body.respond_to?(:to_plain_text)

    body
  end

  def preview
    plain_text_body.truncate(50)
  end

  def recipients
    message_recipients.uniq { |r| r.unit_membership_id }.map(&:unit_membership)
  end

  MAX_RECIPIENT_PREVIEW = 3
end
