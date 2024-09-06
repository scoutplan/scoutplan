# frozen_string_literal: true

class StripePaymentService
  STRIPE_BASE_FEE = 0.30
  STRIPE_PERCENTAGE = 0.029

  attr_accessor :unit

  def initialize(unit)
    @unit = unit
    @payment_account = unit.payment_account
    raise "Unit does not have a payment account" unless @payment_account
  end

  # given an amount, how much will the member's transaction fee be?
  def member_transaction_fee(subtotal)
    return 0 if @payment_account.transaction_fees_covered_by == "unit"

    multiplier = 1.0
    fee = ((subtotal * STRIPE_PERCENTAGE) + STRIPE_BASE_FEE).round(2)
    multiplier = 0.5 if @payment_account.transaction_fees_covered_by == "split_50_50"

    (fee * multiplier).to_i
  end
end
