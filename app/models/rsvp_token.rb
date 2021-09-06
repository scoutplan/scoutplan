class RsvpToken < ApplicationRecord
  belongs_to :user
  belongs_to :event
  validates_presence_of :value
  validates_uniqueness_of :value
  validates_uniqueness_of :user, scope: :event
  before_validation :generate_token, on: [:create]

  # # given an Event, generate "magic link" tokens for all active
  # def self.generate_tokens_for_event(event)
  #   event.unit.memberships.active.each { |membership| RsvpToken.create(user: membership.user, event: self) }
  # end

private

  def generate_token
    self.value = SecureRandom.hex(6)
  end
end
