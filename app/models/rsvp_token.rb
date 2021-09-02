class RsvpToken < ApplicationRecord
  belongs_to :user
  belongs_to :event
  validates_presence_of :token
  validates_uniqueness_of :token
  validates_uniqueness_of :user, scope: :event
  before_create :generate_token

private
  def generate_token
    until self.errors.empty? do
      token = self.token = SecureRandom.hex(8)
    end
  end
end
