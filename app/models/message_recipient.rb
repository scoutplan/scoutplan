# frozen_string_literal: true

class MessageRecipient < ApplicationRecord
  belongs_to :message
  belongs_to :unit_membership

  validates_presence_of :message, :unit_membership
  validates_uniqueness_of :unit_membership_id, scope: :message_id

  delegate :full_display_name, to: :unit_membership

  def self.from_unit_membership(unit_membership)
    new(unit_membership: unit_membership)
  end

  def self.collection_from_unit_memberships(unit_memberships)
    unit_memberships.map { |m| from_unit_membership(m) }
  end

  def description
    full_display_name
  end

  def self.with_guardians(recipients)
    youth_ids = recipients.select(&:youth?).pluck(:id)
    parent_ids = MemberRelationship.where(child_unit_membership_id: youth_ids).pluck(:parent_unit_membership_id)
    parents = UnitMembership.where(id: parent_ids).contactable?
    # (recipients.select(&:contactable?) + parents.contactable?).uniq
    (recipients + parents).uniq.select(&:contactable?)
  end
end
