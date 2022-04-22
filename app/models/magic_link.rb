# frozen_string_literal: true

# A MagicLink is a tokenized path associated with a particular UnitMembership
class MagicLink < ApplicationRecord
  belongs_to :unit_membership
  before_validation :generate_token, on: [:create]
  # after_find :destroy_if_expired!
  validates_presence_of :unit_membership, :token
  validates_uniqueness_of :token
  alias_attribute :member, :unit_membership
  delegate :user, to: :unit_membership

  # does this link expire?
  def expires?
    time_to_live.present?
  end

  # is this link expired?
  def expired?
    return false unless expires?

    DateTime.now.after? expires_at
  end

  # when does this MagicLink expire? Returns nil for non-expiring tokens
  def expires_at
    return nil unless expires?

    updated_at + time_to_live
  end

  # for a given Member and a given path, generate a unique token
  def self.generate_link(member, path, ttl = 120.hours)
    MagicLink.create_with(time_to_live: ttl).find_or_create_by(member: member, path: path)
  end

  def self.generate_non_expiring_link(member, path)
    MagicLink.create_with(time_to_live: nil).find_or_create_by(member: member, path: path)
  end

  private

  def generate_token
    # if you decide to change this to increase keyspace, you'll need to also
    # adjust the regexp on the "magic_link" route in routes.rb as it's hard-wired
    # to a specific token width
    self.token = SecureRandom.hex(6)
  end

  def destroy_if_expired!
    destroy! if expired?
  end
end
