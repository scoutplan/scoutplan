# frozen_string_literal: true

# Purpose: Model for payments made by members to the unit
class Payment < ApplicationRecord
  STRIPE_BASE_FEE = 30.freeze
  STRIPE_PERCENTAGE = 0.029.freeze

  belongs_to :event
  belongs_to :unit_membership
  belongs_to :received_by, class_name: "UnitMembership", optional: true
  validates_presence_of :event, :unit_membership, :amount, :method, :status
  validates_numericality_of :amount, greater_than: 0

  enum status: { pending: "pending", paid: "paid" }
  enum method: { cash: "cash", check: "check", stripe: "stripe", other: "other", zelle: "zelle", venmo: "venmo" }

  delegate :unit, to: :event

  def amount_in_dollars
    (amount || 0) / 100.0
  end

  def transaction_fee
    return 0 unless method == "stripe"

    (amount * STRIPE_PERCENTAGE + STRIPE_BASE_FEE).to_i
  end
end