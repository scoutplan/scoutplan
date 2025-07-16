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
end
