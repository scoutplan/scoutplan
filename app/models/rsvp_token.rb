class RsvpToken < ApplicationRecord
  belongs_to :user
  belongs_to :event
  validates_presence_of :value
  validates_uniqueness_of :value
  validates_uniqueness_of :user, scope: :event
  before_validation :generate_token, on: [:create]

private
  def generate_token
    self.value = SecureRandom.hex(6)
  end
end
