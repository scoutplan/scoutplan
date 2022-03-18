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
    return false unless expires_at.present?

    DateTime.now.after? expires_at
  end

  # for a given Member and a given path, generate a unique token. Pass :never or nil
  # to generate a non-expiring token (good for things like ical subscriptions). Otherwise
  # it'll expire in 5 days.
  #
  # possible usages:
  # e.g. MagicLink.generate_link(@member, "/some/path")
  # e.g. MagicLink.generate_link(@member, "/some/path", 2.weeks.from_now)
  # e.g. MagicLink.generate_link(@member, "/some/path", :never)
  # e.g. MagicLink.generate_link(@member, "/some/path", nil)
  def self.generate_link(member, path, expires_at = 120.hours.from_now)
    expires_at = nil unless expires_at.is_a?(Time)
    MagicLink.create_with(expires_at: expires_at).find_or_create_by(member: member, path: path)
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
