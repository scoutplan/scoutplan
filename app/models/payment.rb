class Payment < ApplicationRecord
  DEFAULT_TRANSACTION_FEE = 0
  STRIPE_BASE_FEE = 30
  STRIPE_RATE = 0.029

  belongs_to :event
  belongs_to :unit_membership
  belongs_to :received_by, class_name: "UnitMembership", optional: true
  validates_presence_of :event, :unit_membership, :amount, :method, :status
  validates_numericality_of :amount

  enum status: { pending: "pending", paid: "paid" }
  enum method: { cash: "cash", check: "check", stripe: "stripe", other: "other", zelle: "zelle", venmo: "venmo" }

  delegate :unit, to: :event
  delegate :payment_account, to: :unit

  def amount_in_dollars
    (amount || 0) / 100.0
  end

  def transaction_fee
    return 0 if payment_account.transaction_fees_covered_by == "unit"

    result = stripe_fee if method == "stripe"
    result /= 2.0 if payment_account.transaction_fees_covered_by == "split_50_50"
    result.to_i
  end

  def stripe_fee
    STRIPE_BASE_FEE + (amount * STRIPE_RATE)
  end
end
