# frozen_string_literal: true

class RsvpToken < ApplicationRecord
  belongs_to :unit_membership
  belongs_to :event
  validates_presence_of :unit_membership, :event, :value
  validates_uniqueness_of :value
  validates_uniqueness_of :unit_membership, scope: :event
  before_validation :generate_token, on: [:create]
  alias_attribute :member, :unit_membership

  # # given an Event, generate "magic link" tokens for all active
  # def self.generate_tokens_for_event(event)
  #   event.unit.memberships.active.each { |membership| RsvpToken.create(user: membership.user, event: self) }
  # end

  delegate :user, to: :unit_membership
  delegate :unit, to: :event

  private

  def generate_token
    self.value = SecureRandom.hex(6)
  end
end
