# frozen_string_literal: true

class StripePaymentService
  STRIPE_BASE_FEE = 0.30
  STRIPE_PERCENTAGE = 0.029

  attr_accessor :unit

  def initialize(unit)
    @unit = unit
    @payment_account = unit.payment_account
  end

  # given an amount, how much will the member's transaction fee be?
  def member_transaction_fee(subtotal)
    return 0 unless @payment_account
    return 0 if @payment_account.transaction_fees_covered_by == "unit"

    multiplier = 1.0
    gross_up = (subtotal + STRIPE_BASE_FEE) / (1 - STRIPE_PERCENTAGE)
    fee = gross_up - subtotal
    # fee = ((subtotal * STRIPE_PERCENTAGE) + STRIPE_BASE_FEE).round(2)
    multiplier = 0.5 if @payment_account.transaction_fees_covered_by == "split_50_50"

    (fee * multiplier).round(2)
  end
end
