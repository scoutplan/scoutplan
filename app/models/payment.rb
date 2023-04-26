# frozen_string_literal: true

# Purpose: Model for payments made by members to the unit
class Payment < ApplicationRecord
  belongs_to :event
  belongs_to :unit_membership

  enum status: { pending: "pending", paid: "paid" }

  def amount_in_dollars
    (amount || 0) / 100.0
  end
end
