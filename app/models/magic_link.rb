# frozen_string_literal: true

# A MagicLink is a tokenized path associated with a particular UnitMembership
class MagicLink < ApplicationRecord
  belongs_to :unit_membership
  before_validation :generate_token, on: [:create]
  before_validation :set_expiration, on: [:create]
  after_find :destroy_if_expired!
  validates_presence_of :unit_membership, :token
  alias_attribute :member, :unit_membership
  delegate :user, to: :unit_membership

  def expired?
    DateTime.now.after? expires_at
  end

  def self.generate_link(member, path)
    MagicLink.find_or_create_by(member: member, path: path)
  end

  private

  def generate_token
    self.token = SecureRandom.hex(6)
  end

  # for now we're just gonna hard-code links to last five (5) days
  def set_expiration
    self.expires_at = 120.hours.from_now
  end

  def destroy_if_expired!
    destroy! if expired?
  end
end
