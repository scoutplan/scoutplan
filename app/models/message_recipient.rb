# frozen_string_literal: true

class MessageRecipient < ApplicationRecord
  belongs_to :message
  belongs_to :unit_membership

  validates_presence_of :message, :unit_membership

  alias_attribute :member, :unit_membership
end
