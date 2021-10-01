# frozen_string_literal: true

# a proxy for a Member to be used for passwordless convenience logins
class MagicLink < ApplicationRecord
  belongs_to :unit_membership
  before_validation :generate_token, on: [:create]
  before_validation :set_expiration, on: [:create]
  after_find :destroy_if_expired!
  validates_presence_of :user, :token
  alias_attribute :member, :unit_membership
  delegate :user, to: :unit_membership

  def expired?
    DateTime.now > expires_at
  end

  private

  def generate_token
    self.token = SecureRandom.hex(6)
  end

  def set_expiration
    self.expires_at = 120.hours.from_now
  end

  def destroy_if_expired!
    destroy! if expired?
  end
end
