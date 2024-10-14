# frozen_string_literal: true

# Purpose: To store the Stripe account information for a unit
class PaymentAccount < ApplicationRecord
  belongs_to :unit

  enum :transaction_fees_covered_by, { member: "member", unit: "unit", split_50_50: "split_50_50" }

  def active?
    account["charges_enabled"] && account["payouts_enabled"]
  end

  def account
    return @account if @account.present?

    Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY")
    @account = Stripe::Account.retrieve(unit.payment_account.account_id)
  end
end
