# frozen_string_literal: true

# A MagicLink is a tokenized path associated with a particular UnitMembership
class MagicLink < ApplicationRecord
  DEFAULT_TTL = 168.hours.freeze

  belongs_to :unit_membership

  before_validation :generate_token!, on: [:create]

  validates_presence_of :unit_membership, :token, :time_to_live

  validates_uniqueness_of :token

  alias_attribute :member, :unit_membership

  delegate :user, to: :unit_membership
  delegate :unit, to: :unit_membership

  scope :expired, -> { where("time_to_live IS NOT NULL AND updated_at + time_to_live * interval '1 second' < ?", DateTime.now) }
  scope :active, -> { where("time_to_live IS NULL OR updated_at + time_to_live * interval '1 second' >= ?", DateTime.now) }

  def expired?
    DateTime.now.after? expires_at
  end

  def expires_at
    created_at + time_to_live
  end

  def self.generate_link(member, path, ttl = DEFAULT_TTL)
    magic_link = member.magic_links.create(path: path, time_to_live: ttl)
  end

  private

  def generate_token!
    self.token = SecureRandom.hex(6)
  end
end
