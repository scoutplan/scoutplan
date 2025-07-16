# frozen_string_literal: true

# Message lifecycle:
# 4. Sender composes a message, adds recipients, and sets a subject, body, and attachments.
# 5. Sender clicks Send. Controller updates status to "outbox"
# 6. The Sendable after_commit hook enqueues a SendMessageJob
# 7. SendMessageJob fires which, in turn, calls Sendable#send! (found in the Sendable concern)
# 8. send! calls Notifiable#recipients to resolve the list of recipients
# 9. send! invokes a MessageNotifier (see the Noticed gem) object and calls .deliver_later, passing in the recipient list
# 10. For each recipient, MessageNotifer enqueues an asynchronous job that sends the message to each recipient via email and/or SMS, depending on their contact preferences

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

  def dup
    super.tap do |new_message|
      new_message.regenerate_token
      new_message.body = body.dup
      new_message.status = :draft
      new_message.title.prepend("Copy of ")
      message_recipients.each do |message_recipient|
        new_message.message_recipients << message_recipient.dup
      end
      new_message.save
    end
  end

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
