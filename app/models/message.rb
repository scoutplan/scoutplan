# frozen_string_literal: true

# represents a communication from a person to one or more recipients
class Message < ApplicationRecord
  belongs_to :unit_membership
  alias_attribute :member, :unit_membership
  has_many :message_recipients
end
